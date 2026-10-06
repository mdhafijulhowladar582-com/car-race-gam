extends Control

var log_label: Label
var lines: Array[String] = []

func _ready() -> void:
    set_anchors_preset(Control.PRESET_FULL_RECT)
    var layer := CanvasLayer.new()
    layer.layer = 100
    add_child(layer)
    var bg := ColorRect.new()
    bg.color = Color(0, 0, 0, 0.78)
    bg.position = Vector2(8, 8)
    bg.size = Vector2(560, 300)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(bg)
    log_label = Label.new()
    log_label.position = Vector2(16, 12)
    log_label.size = Vector2(545, 290)
    log_label.add_theme_font_size_override("font_size", 16)
    log_label.add_theme_color_override("font_color", Color(1, 1, 1))
    log_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(log_label)

    _log("BOOT START")
    _log("Godot " + Engine.get_version_info().get("string", "?"))
    _log("Plugin singleton: " + str(Engine.has_singleton("FirebaseGoogleSignIn")))

    for path in ["res://scripts/ai_car.gd", "res://scripts/player_car.gd", "res://scripts/firebase_service.gd", "res://scripts/google_signin.gd", "res://scripts/main.gd"]:
        var res: Resource = load(path)
        if res == null:
            _log("FAIL load: " + path)
        elif res is GDScript:
            var ok: bool = (res as GDScript).can_instantiate()
            _log(("OK   " if ok else "FAIL ") + path.get_file() + "  can_instantiate=" + str(ok))
        else:
            _log("?? " + path)

    var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
    if packed == null:
        _log("FAIL: main.tscn load")
        return
    var inst: Node = packed.instantiate()
    if inst == null:
        _log("FAIL: main.tscn instantiate")
        return
    _log("main.tscn instantiated, script=" + str(inst.get_script() != null))
    add_child(inst)
    _log("main added, children=" + str(inst.get_child_count()))
    await get_tree().create_timer(1.5).timeout
    if not is_instance_valid(inst):
        _log("main freed!")
        return
    _log("after 1.5s children=" + str(inst.get_child_count()))
    var tp = inst.get("track_path")
    _log("track_path size=" + (str(tp.size()) if tp != null else "null"))
    var cam := get_viewport().get_camera_3d()
    _log("camera=" + (str(cam.global_position) if cam != null else "NONE"))
    _log("(healthy: children > 30, track_path > 0)")

func _log(msg: String) -> void:
    lines.append(msg)
    print("[BOOT] ", msg)
    if log_label:
        log_label.text = "\n".join(lines)
