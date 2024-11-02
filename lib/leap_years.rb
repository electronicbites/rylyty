#http://stackoverflow.com/q/1904097/320225
module LeapYears

  def years_completed_since(start_date, end_date)
    if end_date < start_date
      raise ArgumentError.new(
        "End date supplied (#{end_date}) is before start date (#{start_date})"
      )
    end
    years_completed = end_date.year - start_date.year
    unless reached_anniversary_in_year_of(start_date, end_date)
      years_completed -= 1
    end
    years_completed
  end

  # No special logic required for leap day; its anniversary in a non-leap
  # year is considered to have been reached on March 1.
  def reached_anniversary_in_year_of(original_date, new_date)
    if new_date.month == original_date.month
      new_date.day >= original_date.day
    else
      new_date.month > original_date.month
    end
  end
end