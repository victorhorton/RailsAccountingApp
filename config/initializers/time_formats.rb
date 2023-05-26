Date::DATE_FORMATS[:masked] = ->(date) {
  date.strftime("%m-%d-%y")
}
