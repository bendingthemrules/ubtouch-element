package main

import (
	pushnotifications "element-client/push"

	"encoding/json"
	"fmt"
	"os"
)

type MatrixNotification struct {
	Message struct {
		Content struct {
			Body          string `json:"body"`
			Format        string `json:"format"`
			FormattedBody string `json:"formatted_body"`
			Msgtype       string `json:"msgtype"`
			Membership    string `json:"membership"`
		} `json:"content"`
		Counts struct {
			Unread      int `json:"unread"`
			MissedCalls int `json:"missed_calls"`
		} `json:"counts"`
		Devices []struct {
			AppID string `json:"app_id"`
			Data  struct {
				Format string `json:"format"`
			} `json:"data"`
			Pushkey   string `json:"pushkey"`
			PushkeyTs int    `json:"pushkey_ts"`
			Tweaks    struct {
				Highlight bool   `json:"highlight"`
				Sound     string `json:"sound"`
			} `json:"tweaks"`
		} `json:"devices"`
		EventID           string `json:"event_id"`
		ID                string `json:"id"`
		RoomID            string `json:"room_id"`
		RoomAlias         string `json:"room_alias"`
		UserIsTarget      bool   `json:"user_is_target"`
		Prio              string `json:"prio"`
		Sender            string `json:"sender"`
		SenderDisplayName string `json:"sender_display_name"`
		Type              string `json:"type"`
	} `json:"message"`
}

func main() {
	fmt.Println("Handling push notification")

	args := os.Args[1:3]

	firstFileBytes, err := os.ReadFile(args[0])
	if err != nil {
		fmt.Println("Error reading file", err)
		return
	}

	fmt.Println(args[0], ":", string(firstFileBytes))

	var pushMessage MatrixNotification
	err = json.Unmarshal(firstFileBytes, &pushMessage)

	if err != nil {
		fmt.Println("Could not unmarshal push message", err)
		return
	}

	message := pushMessage.Message.Content.Body
	if message == "" {
		message = "New message"
	}

	push := pushnotifications.PushMessage{
		Notification: pushnotifications.Notification{
			Card: pushnotifications.Card{
				Summary: message,
				Body:    message,
				Popup:   true,
				Persist: true,
				Actions: []string{"btrelement://room#" + pushMessage.Message.RoomID},
			},
			Vibrate: true,
			Sound:   true,
		},
		Message: pushnotifications.Message{
			Body:   message,
			LocKey: "message",
			LocArgs: []string{
				pushMessage.Message.SenderDisplayName,
				pushMessage.Message.Content.Body,
			},
			Custom: pushnotifications.Custom{
				MsgId:  pushMessage.Message.EventID,
				FromId: pushMessage.Message.Sender,
			},
		},
	}

	pushMessageBytes, err := json.Marshal(push)
	if err != nil {
		fmt.Println("Could not marshal push message", err)
		return
	}

	writeErr := os.WriteFile(args[1], pushMessageBytes, os.ModeDevice)
	if writeErr != nil {
		fmt.Println("Could not write file", writeErr)
		return
	}
}
