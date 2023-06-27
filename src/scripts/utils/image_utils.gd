class_name ImageUtils
extends RefCounted
# maybe could extend Object, but not 100% sure


const BMP_MAGIC = "424d"
const JPEG_MAGIC = "ffd8ff"
const PNG_MAGIC = "89504e470d0a1a0a"
const WEBP_MAGIC = "52494646"
## length of the longest file magic in bytes
@warning_ignore("integer_division")
const MAX_MAGIC_LEN = len(PNG_MAGIC) / 2


## load a Image file from a byte array and create an ImageTexture from it
static func load_image_texture_from_bytes(buffer: PackedByteArray) -> ImageTexture:
	var img := Image.new()

	var buffer_magic := buffer.slice(0, MAX_MAGIC_LEN).hex_encode()
	
	if buffer_magic.begins_with(WEBP_MAGIC):
		img.load_webp_from_buffer(buffer)
	elif buffer_magic.begins_with(PNG_MAGIC):
		img.load_png_from_buffer(buffer)
	elif buffer_magic.begins_with(JPEG_MAGIC):
		img.load_jpg_from_buffer(buffer)
	elif buffer_magic.begins_with(BMP_MAGIC):
		img.load_bmp_from_buffer(buffer)
	else:
		print("unknown file type")
		breakpoint
		img.load_tga_from_buffer(buffer)
	
	
#	print("img size: ", img.get_size())
	var tex := ImageTexture.create_from_image(img)
	if tex == null:
		breakpoint
	return tex


## load a Image file from the filesystem and create an ImageTexture from it
static func load_image_texture_from_path(path: String) -> ImageTexture:
	if not FileAccess.file_exists(path):
		print("image not found")
		return
	var buffer := FileAccess.get_file_as_bytes(path)
	if buffer.is_empty():
		print("image is an empty file")
		return
#	print("file size: ", buffer.size())
	return load_image_texture_from_bytes(buffer)


## load a Image file from an url and create an ImageTexture from it
static func load_image_texture_from_url(url: String) -> ImageTexture:
	var headers = [
		"User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/113.0",
		"Referer: "+ "/".join(url.split("/").slice(0, 3))
	]
	var resp := await Requests.get_req(url, headers)
	if resp.err:
		return ImageTexture.new()
	return load_image_texture_from_bytes(resp.body)
