@tool
extends TextureRect

class_name AnimatedTextureRect

@export_tool_button("Toggle Preview Animation") var _editorPreview = _EditorPlayToggle
@export var spriteFrames : SpriteFrames : 
	get:
		return spriteFrames
	set(val):
		spriteFrames = val
		_SetTexture()
@export var animation : String = "default" : 
	set(val):
		animation = val
@export var currentFrameIndex : int = 0
@export_range(0.5, 90.0) var framesPerSecond : float = 2.0 :
	get:
		return framesPerSecond
	set(val):
		framesPerSecond = val
		if !daTimer:
			_TimerSetUp()
		_SetTimerWaitTime()
		

@export var playOnReady := true
var daTimer : Timer
var isPlaying := false
var _isPlayingEditor := false
var _isAllowedToPlayInEditor := true

func _ready() -> void:
	if not Engine.is_editor_hint():
		_isAllowedToPlayInEditor = false
		_isPlayingEditor = false
		if playOnReady:
			Play()
			
	#below is a way to prevent errors on tool buttons in the console :)
	if false:
		print(str(
			_editorPreview
		))
		
	

func Play():
	_KillTimer()
	_SetTexture()
	isPlaying = true
	if !daTimer:
		_TimerSetUp()
	_SetTimerWaitTime()
	daTimer.start()
	

func Stop():
	_KillTimer()
	isPlaying = false
	

func _EditorPlayToggle():
	if _isPlayingEditor:
		_isPlayingEditor = false
		_KillTimer()
		return
	_SetTexture()
	_isPlayingEditor = true
	if !daTimer:
		_TimerSetUp()
	_SetTimerWaitTime()
	daTimer.start()
	


func _PlayNextFrame():
	if _IsNotAllowedToRun():
		_KillTimer()
		return
		
	var tempAnimationName : String = _GetRealAnimationName()
	currentFrameIndex += 1
	if currentFrameIndex >= spriteFrames.get_frame_count(tempAnimationName):
		currentFrameIndex = 0
		
	_SetTexture()
	

func _GetRealAnimationName() -> String:
	return animation if spriteFrames.get_animation_names().has(animation) else spriteFrames.get_animation_names()[0]
	

func _SetTexture():
	if !spriteFrames:
		return
	var tempAnimationName : String = _GetRealAnimationName()
	if currentFrameIndex >= spriteFrames.get_frame_count(tempAnimationName):
		currentFrameIndex = 0
	texture = spriteFrames.get_frame_texture(tempAnimationName, currentFrameIndex)
	

func _TimerSetUp():
	daTimer = Timer.new()
	add_child(daTimer)
	daTimer.autostart = false
	daTimer.timeout.connect(_on_frame_end_timeout)
	

func _SetTimerWaitTime():
	daTimer.wait_time = 1.0 / framesPerSecond
	

func _IsNotAllowedToRun():
	return !isPlaying && (
		!_isAllowedToPlayInEditor || 
		!_isPlayingEditor
		
	)
	

func _KillTimer():
	if daTimer:
		daTimer.stop()
		daTimer.free()
	

func _on_frame_end_timeout():
	if _IsNotAllowedToRun():
		_KillTimer()
		return
		
	_PlayNextFrame()
	
