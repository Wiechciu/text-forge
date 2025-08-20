extends ConfirmationDialog


signal closed


func _ready() -> void:
	confirmed.connect(closed.emit)
	canceled.connect(closed.emit)
