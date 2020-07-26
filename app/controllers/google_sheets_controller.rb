class GoogleSheetsController < ApplicationController
  before_action :authenticate_account

  # name, description, link, kind, start_time, end_time, image_url, host, public_link, invites: []
  #  0    1            2     3     4           5          6          7     8            9
  # POST /google_sheets/import_events
  def import_events
    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title('import_events')
    worksheet = spreadsheet.worksheets.first
    rows = worksheet.rows
    headers, *data = rows

    data.each{ 
      |r|

      @event = Event.new(name: r[0], kind: r[3])
      @event.description = r[1] if r[1]
      @event.link = r[2] if r[2]
      @event.image_url = r[6] if r[6]
      @event.host = r[7] if r[7]
      @event.public_link = r[8] if (r[8] && r[3] == 'open')
  
      @event.start_time = DateTime.iso8601(r[4]) if r[4]
      @event.end_time = DateTime.iso8601(r[5]) if r[5]
  
      if @event.save
  
        if @event.kind === 'invite-only' && r[9]
          r[9].split(", ").each do |email|
            a = Account.find_or_create_by(email: email)
            @event.invitations.create!(account: a)
          end
        end
  
      else
        puts @event.errors
      end
    }

    render(json: { message: "Import successful!" })
  end

  # POST /google_sheets/export_registered
  def export_registered
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    @event = Event.find(google_sheet_params[:event_id])
    render(json: { message: 'Event does not exist' }, status: :unprocessable_entity) if @event.blank?

    @registered = @event.registrations.where(registered: true)

    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title('export_registered')
    worksheet = spreadsheet.worksheets.first

    worksheet.insert_rows(worksheet.num_rows + 1,
      [
        ["Event Id:", @event.id.to_s],
        ["Name:", @event.name],
        ["Hosted by:", @event.host],
        ["Kind:", @event.kind],
        ["Start Time:", @event.start_time.to_s],
        ["End Time:", @event.end_time.to_s],
        [""],
        ["Logged In?", "Account Type", "Account Name", "Account Email", "Account Phone", \
          "Ip Address", "Public Name", "Public Email", "Registered?", "Joined?"],
      ]
    )

    @registered.each{ |r|
      if !r.account.blank?
        worksheet.insert_rows(worksheet.num_rows + 1,
          [
            ["Yes", r.account.user_type, r.account.name, r.account.email, r.account.phone, "N/A", "N/A", "N/A", r.registered, r.joined],
          ]
        )
      else
        worksheet.insert_rows(worksheet.num_rows + 1,
          [
            ["No", "N/A", "N/A", "N/A", "N/A", r.ip_address, r.public_name, r.public_email, r.registered, r.joined],
          ]
        )
      end 
    }

    worksheet.insert_rows(worksheet.num_rows + 1,
      [
        ["-"],
      ]
    )

    worksheet.save

    render(json: { message: 'Export successful!'})
  end

  # POST /google_sheets/export_joined
  def export_joined
    render(json: { message: 'You are not master' }, status: :unauthorized) unless is_master

    @event = Event.find(google_sheet_params[:event_id])
    render(json: { message: 'Event does not exist' }, status: :unprocessable_entity) if @event.blank?

    @joined = @event.registrations.where(joined: true)

    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title('export_joined')
    worksheet = spreadsheet.worksheets.first

    worksheet.insert_rows(worksheet.num_rows + 1,
      [
        ["Event Id:", @event.id.to_s],
        ["Name:", @event.name],
        ["Hosted by:", @event.host],
        ["Kind:", @event.kind],
        ["Start Time:", @event.start_time.to_s],
        ["End Time:", @event.end_time.to_s],
        [""],
        ["Logged In?", "Account Type", "Account Name", "Account Email", "Account Phone", \
          "Ip Address", "Public Name", "Public Email", "Registered?", "Joined?"],
      ]
    )

    @joined.each{ |r| 
      if !r.account.blank?
        worksheet.insert_rows(worksheet.num_rows + 1,
          [
            ["Yes", r.account.user_type, r.account.name, r.account.email, r.account.phone, "N/A", "N/A", "N/A", r.registered, r.joined],
          ]
        )
      else
        worksheet.insert_rows(worksheet.num_rows + 1,
          [
            ["No", "N/A", "N/A", "N/A", "N/A", r.ip_address, r.public_name, r.public_email, r.registered, r.joined],
          ]
        )
      end 
    }

    worksheet.insert_rows(worksheet.num_rows + 1,
      [
        ["-"],
      ]
    )

    worksheet.save

    render(json: { message: 'Export successful!'})
  end

  # mentee_name	mentor_name	mentee_email	mentor_email	mentee_phone	mentor_phone
  #  0           1           2             3             4             5
  # POST /google_sheets/import_mentee_mentor
  def import_mentee_mentor
    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title('import_mentee_mentor')
    worksheet = spreadsheet.worksheets.first
    rows = worksheet.rows
    headers, *data = rows

    data.each{ 
      |r|

      # first create the mentee record
      mentee_account = Account.find_by(email: r[2])

      if mentee_account.blank?
        @mentee = Mentee.new()

        @mentee.account = Account.new(user: @mentee, email: r[2], phone: r[4], name: r[0])

        if @mentee.save
        else
          puts @mentee.errors
        end

      else
        puts 'Account already exists'
        
        @mentee = mentee_account.user

        mentee_account.update(email: r[3], phone: r[5], name: r[0])
        
        if mentee_account.save
        else
          puts mentee_account.errors
        end
      end

      # now create the mentor record
      mentor_account = Account.find_by(email: r[3])

      if mentor_account.blank?
        @mentor = Mentor.new()

        @mentor.account = Account.new(user: @mentor, email: r[3], phone: r[5], name: r[1])

        if @mentor.save
        else
          puts @mentor.errors
        end

      else
        puts 'Account already exists'
        
        @mentor = mentor_account.user

        mentor_account.update(email: r[3], phone: r[5], name: r[1])
        
        if mentor_account.save
        else
          puts mentor_account.errors
        end
      end

      # now match mentee and mentor
      @mentee.mentor = @mentor

      if @mentee.save
      else
        puts @mentee.errors
      end
    }

    render(json: { message: 'Import successful!' })
  end

  private
  
  def google_sheet_params
    params.permit([:file_name, :event_id])
  end

end
