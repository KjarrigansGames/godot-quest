extends VBoxContainer

signal quest_changed(quest, state)

export var max_quests = 20
enum STATE {Unknown, Accepted, Active, Aborted, Failed, Success}
const STATE_COLOR = {
	STATE.Accepted: Color.white,
	STATE.Active: Color.yellow,
	STATE.Aborted: Color.orange,
	STATE.Failed: Color.red,
	STATE.Success: Color.green
}

var quests = [
	preload("res://quests/1_Damsel.tres"),
	preload("res://quests/2_Kjarrigan.tres")
]

func _ready():
	connect("quest_changed", self, "_update_quest_list")
	$Quest/Lists/InProgress.connect("item_selected", self, "_update_quest_preview_1")
	$Quest/Lists/Finished.connect("item_selected", self, "_update_quest_preview_2")
	
func _find_quest_idx(quest):
	for ele in range($Quest/Lists/InProgress.get_item_count()):
		var meta = $Quest/Lists/InProgress.get_item_metadata(ele)
		if meta == quest:
			return ele
	return -1
	
func _add_quest_to_list(list, quest, state):
	list.add_item(quest.title)
	var idx = list.get_item_count()-1
	list.set_item_metadata(idx, quest)
	list.set_item_custom_fg_color(idx, STATE_COLOR[state])
	
func _update_quest_list(quest, state):
	match state:
		STATE.Accepted:
			_add_quest_to_list($Quest/Lists/InProgress, quest, state)
			$Quest/Lists/InProgress.sort_items_by_text()
		STATE.Aborted:
			var idx = _find_quest_idx(quest)
			if idx > -1:
				$Quest/Lists/InProgress.remove_item(idx)
				_add_quest_to_list($Quest/Lists/Finished, quest, state)
				$Quest/Lists/Finished.sort_items_by_text()
				
func _update_quest_preview_1(idx):
	var q = $Quest/Lists/InProgress.get_item_metadata(idx)
	$Quest/Lists/Preview/Section/Title.text = q.title
	$Quest/Lists/Preview/Section/Description.text = q.description
	
func _on_New_pressed():
	quests.shuffle()
	emit_signal("quest_changed", quests[0], STATE.Accepted)

func _on_Abort_pressed():
	if not $Quest/Lists/InProgress.is_anything_selected():
		return
		
	for ele in $Quest/Lists/InProgress.get_selected_items():
		emit_signal("quest_changed", $Quest/Lists/InProgress.get_item_metadata(ele), STATE.Aborted)
