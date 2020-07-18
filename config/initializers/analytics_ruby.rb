Analytics = Segment::Analytics.new({
  write_key: "rQyUdK2oj0woAcGYS645DiHyIlfv8mfG",
  on_error: proc { |_status, msg| puts msg },
})