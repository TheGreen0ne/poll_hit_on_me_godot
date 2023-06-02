class_name StringUtils
extends RefCounted


## for every line deletes everything before the carriage return character "\r"
## and the character itself
static func apply_cr(s: String) -> String:
	if not "\r" in s:
		return s

	var lines := s.split("\n")
	var i := 0
	for line in lines:
		lines[i] = apply_cr_single_line(line)
		i += 1
	return "\n".join(lines)


## deletes everything before the carriage return character "\r"
## and the character itself
static func apply_cr_single_line(line: String) -> String:
	if not "\r" in line:
		return line

	var parts := line.rsplit("\r", false, 1)
	if parts.is_empty():
		return ""
	return parts[-1]
