extends SceneTree
## Original 5x7 bitmap alphabet. Lowercase maps to small-cap forms intentionally.
const GLYPHS: Dictionary = {
"A":"01110/10001/10001/11111/10001/10001/10001",
"B":"11110/10001/10001/11110/10001/10001/11110",
"C":"01111/10000/10000/10000/10000/10000/01111",
"D":"11110/10001/10001/10001/10001/10001/11110",
"E":"11111/10000/10000/11110/10000/10000/11111",
"F":"11111/10000/10000/11110/10000/10000/10000",
"G":"01111/10000/10000/10111/10001/10001/01110",
"H":"10001/10001/10001/11111/10001/10001/10001",
"I":"111/010/010/010/010/010/111",
"J":"00111/00010/00010/00010/10010/10010/01100",
"K":"10001/10010/10100/11000/10100/10010/10001",
"L":"10000/10000/10000/10000/10000/10000/11111",
"M":"10001/11011/10101/10101/10001/10001/10001",
"N":"10001/11001/10101/10011/10001/10001/10001",
"O":"01110/10001/10001/10001/10001/10001/01110",
"P":"11110/10001/10001/11110/10000/10000/10000",
"Q":"01110/10001/10001/10001/10101/10010/01101",
"R":"11110/10001/10001/11110/10100/10010/10001",
"S":"01111/10000/10000/01110/00001/00001/11110",
"T":"11111/00100/00100/00100/00100/00100/00100",
"U":"10001/10001/10001/10001/10001/10001/01110",
"V":"10001/10001/10001/10001/10001/01010/00100",
"W":"10001/10001/10001/10101/10101/11011/10001",
"X":"10001/10001/01010/00100/01010/10001/10001",
"Y":"10001/10001/01010/00100/00100/00100/00100",
"Z":"11111/00001/00010/00100/01000/10000/11111",
"0":"01110/10001/10011/10101/11001/10001/01110",
"1":"010/110/010/010/010/010/111",
"2":"01110/10001/00001/00010/00100/01000/11111",
"3":"11110/00001/00001/01110/00001/00001/11110",
"4":"00010/00110/01010/10010/11111/00010/00010",
"5":"11111/10000/10000/11110/00001/00001/11110",
"6":"01110/10000/10000/11110/10001/10001/01110",
"7":"11111/00001/00010/00100/01000/01000/01000",
"8":"01110/10001/10001/01110/10001/10001/01110",
"9":"01110/10001/10001/01111/00001/00001/01110",
":":"0/1/1/0/1/1/0", ".":"0/0/0/0/0/1/1",
"/":"00001/00001/00010/00100/01000/10000/10000",
"-":"000/000/000/111/000/000/000",
"[":"111/100/100/100/100/100/111", "]":"111/001/001/001/001/001/111",
"?":"01110/10001/00001/00010/00100/00000/00100",
"—":"00000/00000/00000/11111/00000/00000/00000",
" ":"000/000/000/000/000/000/000"
}
func _initialize() -> void:
	var chars: Array = GLYPHS.keys()
	for code in range(97,123):
		chars.append(String.chr(code))
	var image := Image.create(128,48,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var lines: String = 'info face="After Hours Pixel" size=8 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=1,1\n'
	lines += 'common lineHeight=10 base=8 scaleW=128 scaleH=48 pages=1 packed=0\npage id=0 file="after_hours.png"\nchars count=%d\n' % chars.size()
	for i in range(chars.size()):
		var ch: String = chars[i]
		var rows: PackedStringArray = String(GLYPHS[ch.to_upper()]).split("/")
		var x: int = (i % 16)*8
		var y: int = (i / 16)*8
		for row in range(7):
			for col in range(rows[row].length()):
				if rows[row][col] == "1":
					image.set_pixel(x+col,y+row,Color.WHITE)
		var width: int = rows[0].length()
		lines += "char id=%d x=%d y=%d width=%d height=7 xoffset=0 yoffset=1 xadvance=%d page=0 chnl=15\n" % [ch.unicode_at(0),x,y,width,width+1]
	image.save_png("res://assets/fonts/after_hours.png")
	var file := FileAccess.open("res://assets/fonts/after_hours.fnt",FileAccess.WRITE)
	file.store_string(lines)
	file.close()
	# Embed glyph texture data so the project theme also loads before first import.
	var font := FontFile.new()
	var error: int = font.load_bitmap_font("res://assets/fonts/after_hours.fnt")
	if error == OK:
		font.fixed_size_scale_mode = 2 # Integer scaling only (8px, 16px, ...).
		error = ResourceSaver.save(font,"res://assets/fonts/after_hours.tres")
	quit(0 if error == OK else 1)
