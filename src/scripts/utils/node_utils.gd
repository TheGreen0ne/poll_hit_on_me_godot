class_name NodeUtils
extends RefCounted


static func find_parent_of_class(thiz: Node, clazz):
	var parent := thiz.get_parent()
	while parent != null and not is_instance_of(parent, clazz):
		parent = parent.get_parent()
	return parent
