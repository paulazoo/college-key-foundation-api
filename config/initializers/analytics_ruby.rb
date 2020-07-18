Analytics = Segment::Analytics.new({
  write_key: "U0lpKCstdjcCL2OmYEncrRbPpkxA7II7",
  on_error: proc { |_status, msg| puts msg },
})