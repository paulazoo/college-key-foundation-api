Analytics = Segment::Analytics.new({
  write_key: "x4crAfKKYX0i3mvBbD6dca66xLt0JZ4z",
  on_error: proc { |_status, msg| puts msg },
})