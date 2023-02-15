package pushnotifications

type PushMessage struct {
	Message      `json:"message"`
	Notification `json:"notification"`
}

type Message struct {
	Body    string   `json:"body"`
	LocKey  string   `json:"loc_key"`
	LocArgs []string `json:"loc_args"`
	Custom  `json:"custom"`
}

type Custom struct {
	MsgId  string `json:"msg_id"`
	FromId string `json:"from_id"`
}

type Notification struct {
	Tag           string `json:"tag"`
	Card          `json:"card"`
	Sound         bool `json:"sound"`
	Vibrate       bool `json:"vibrate"`
	EmblemCounter `json:"emblem-counter"`
}

type Card struct {
	Icon    string   `json:"icon"`
	Summary string   `json:"summary"`
	Body    string   `json:"body"`
	Popup   bool     `json:"popup"`
	Persist bool     `json:"persist"`
	Actions []string `json:"actions"`
}

type Vibrate struct {
	Pattern  []int `json:"pattern"`
	Duration int   `json:"duration"`
	Repeat   int   `json:"repeat"`
}

type EmblemCounter struct {
	Count   int  `json:"count"`
	Visible bool `json:"visible"`
}
