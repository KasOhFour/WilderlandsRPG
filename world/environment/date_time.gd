# date_time.gd
class_name DateTime
extends Node

signal year_ticked(year: int)
signal season_ticked(season: Season)
signal day_ticked(day: int)
signal hour_ticked(hour: int)
signal minute_ticked(minute: int)

enum Season {
	UNDEFINED,
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER,
}

const DELTA_PER_DAY := 30.0 # 15 minutes per save cycle, 30 minutes per day.
const ON_SAVE_SKIP_HOURS := 2
const MINUTES_PER_TICK := 10
const MORNING_START_HOUR := 8
const EVENING_START_HOUR := 20
const MINUTES_PER_HOUR := 60
const HOURS_PER_DAY := 24
const DAYS_PER_SEASON := 28
const SEASONS_PER_YEAR := 4
const MINUTES_PER_DAY := MINUTES_PER_HOUR * HOURS_PER_DAY
const MINUTES_PER_SEASON := MINUTES_PER_DAY * DAYS_PER_SEASON
const MINUTES_PER_YEAR := MINUTES_PER_SEASON * SEASONS_PER_YEAR
const DELTA_PER_TICK := (
DELTA_PER_DAY
/ float(24 * 60 - ON_SAVE_SKIP_HOURS * 60 * 2)
* float(MINUTES_PER_TICK)
)
#const DELTA_PER_TICK := (
	#DELTA_PER_DAY
	#/ float(24 * 60)
	#* float(MINUTES_PER_TICK)
#)

var year: int
var season: Season
var day: int
var hour: int
var minute: int
var tick_delta := 0.0
var normal_delta := 0.0
var is_paused := false


@warning_ignore("shadowed_variable")
static func is_save_hour(hour: int) -> bool:
	if hour == MORNING_START_HOUR - ON_SAVE_SKIP_HOURS:
		return true
	if hour == EVENING_START_HOUR - ON_SAVE_SKIP_HOURS:
		return true
	return false


@warning_ignore("shadowed_variable")
func _init(
		year := 1,
		season := Season.SPRING,
		day := 1,
		hour := MORNING_START_HOUR,
		minute := 0,
) -> void:
	set_time(
		year,
		season,
		day,
		hour,
		minute,
	)


func _process(delta: float) -> void:
	if not is_paused:
		tick_delta += delta
		normal_delta = fposmod(normal_delta + delta / DELTA_PER_DAY, 1.0)
		if tick_delta >= DELTA_PER_TICK:
			tick_delta -= DELTA_PER_TICK
			advance_minutes(MINUTES_PER_TICK)


func pause() -> void:
	is_paused = true


func unpause() -> void:
	is_paused = false


func get_total_minutes() -> int:
	return (
		year * MINUTES_PER_YEAR
		+ season * MINUTES_PER_SEASON
		+ day * MINUTES_PER_DAY
		+ hour * MINUTES_PER_HOUR
		+ minute
	)


func get_string_time(format: String = "$Se $DD, Year $Y, $HH:$MM $Me") -> String:
	var result := format
	var season_name := Util.enum_string(DateTime.Season, season)
	var standard_hour := Util.standard_hour(hour)
	var meridiem := "AM" if hour < 12 else "PM"

	result = result.replace("$Y", str(year))
	result = result.replace("$Se", season_name.capitalize())
	result = result.replace("$SE", season_name.to_upper())
	result = result.replace("$SN", str(season))
	result = result.replace("$DD", "%02d" % day)
	result = result.replace("$D", str(day))
	result = result.replace("$HH", "%02d" % standard_hour)
	result = result.replace("$H", str(standard_hour))
	result = result.replace("$hh", "%02d" % hour)
	result = result.replace("$h", str(hour))
	result = result.replace("$MM", "%02d" % minute)
	result = result.replace("$Me", meridiem)

	return result


func advance_minutes(minutes: int, suppress_signals := false) -> void:
	var total_minutes := get_total_minutes() + minutes
	var old_year := year
	var old_season := season
	var old_day := day
	var old_hour := hour
	var old_minute := minute

	@warning_ignore("integer_division")
	year = total_minutes / MINUTES_PER_YEAR
	total_minutes %= MINUTES_PER_YEAR

	@warning_ignore("integer_division", "int_as_enum_without_cast")
	season = total_minutes / MINUTES_PER_SEASON
	total_minutes %= MINUTES_PER_SEASON

	@warning_ignore("integer_division")
	day = total_minutes / MINUTES_PER_DAY
	total_minutes %= MINUTES_PER_DAY

	@warning_ignore("integer_division")
	hour = total_minutes / MINUTES_PER_HOUR
	minute = total_minutes % MINUTES_PER_HOUR

	normal_delta = float(hour * 60 + minute) / float(24 * 60)

	if not suppress_signals:
		if old_year != year:
			minute_ticked.emit(minute)
			hour_ticked.emit(hour)
			day_ticked.emit(day)
			season_ticked.emit(season)
			year_ticked.emit(year)
		elif old_season != season:
			minute_ticked.emit(minute)
			hour_ticked.emit(hour)
			day_ticked.emit(day)
			season_ticked.emit(season)
		elif old_day != day:
			minute_ticked.emit(minute)
			hour_ticked.emit(hour)
			day_ticked.emit(day)
		elif old_hour != hour:
			minute_ticked.emit(minute)
			hour_ticked.emit(hour)
		elif old_minute != minute:
			minute_ticked.emit(minute)


func advance_by(
		date_time: Dictionary[String, int],
		suppress_signals := false,
) -> void:
	var minutes := 0

	minutes += date_time.get("year", 0) * MINUTES_PER_YEAR
	minutes += date_time.get("season", 0) * MINUTES_PER_SEASON
	minutes += date_time.get("day", 0) * MINUTES_PER_DAY
	minutes += date_time.get("hour", 0) * MINUTES_PER_HOUR
	minutes += date_time.get("minute", 0)

	advance_minutes(minutes, suppress_signals)


@warning_ignore("shadowed_variable")
func set_time(
		year: int,
		season: Season,
		day: int,
		hour: int,
		minute: int,
) -> void:
	self.year = year
	self.season = season
	self.day = day
	self.hour = hour
	self.minute = minute
	normal_delta = float(hour * 60 + minute) / float(24 * 60)


func skip_hours_from_save() -> void:
	advance_by(
		{ "hour": 2 },
		true,
	)
