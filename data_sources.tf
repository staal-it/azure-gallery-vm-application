resource "time_static" "today" {}

resource "time_offset" "tomorrow" {
  offset_days = 1
}


