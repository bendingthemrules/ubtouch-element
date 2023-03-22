package element

import (
	"element-client/files"
	"fmt"

	"github.com/matrix-org/gomatrix"

	"github.com/therecipe/qt/core"
)

type QServer struct {
	core.QObject
	_ string `property:"domain"`
	_ string `property:"description"`
	_ bool   `property:"selected"`
	_ int    `property:"totalUsers"`
	_ string `property:"language"`
}

type QClient struct {
	core.QAbstractListModel

	_ func() `constructor:"init"`

	_ string `property:"webviewUrl"`
	_ string `property:"pushNotificationToken"`

	_ func() bool                                                                              `slot:"notificationsEnabled"`
	_ func(userID string, accessToken string, homeServer string, pushNotificationToken string) `slot:"registerNotifications"`
}

func (m *QClient) init() {
	m.ConnectRegisterNotifications(m.registerNotifications)
	m.ConnectNotificationsEnabled(m.notificationsEnabled)
}

type PusherData struct {
	Lang              string `json:"lang"`
	Kind              string `json:"kind"`
	AppDisplayName    string `json:"app_display_name"`
	DeviceDisplayName string `json:"device_display_name"`
	ProfileTag        string `json:"profile_tag"`
	AppID             string `json:"app_id"`
	Pushkey           string `json:"pushkey"`
	Data              struct {
		URL    string `json:"url"`
		Format string `json:"format`
	} `json:"data"`
	Append bool `json:"append"`
}

func (m *QClient) notificationsEnabled() bool {
	return files.FileExists("/home/phablet/.local/share/nl.btr.element/element.txt")
}

func (m *QClient) registerNotifications(userID string, accessToken string, homeServer string, pushNotificationToken string) {
	if files.FileExists("/home/phablet/.local/share/nl.btr.element/element.txt") == false {

		if pushNotificationToken == "" {
			fmt.Println("No push notification token")
			return
		}

		fmt.Println("Registering notifications")

		cli, err := gomatrix.NewClient(homeServer, userID, accessToken)
		if err != nil {
			fmt.Println("Error creating client", err)
			return
		}

		err = cli.MakeRequest("POST", homeServer+"/_matrix/client/v3/pushers/set", &PusherData{
			Lang:              "en",
			Kind:              "http",
			AppDisplayName:    "Matrix",
			DeviceDisplayName: "Matrix",
			ProfileTag:        "matrix",
			AppID:             "nl.btr.element_element",
			Pushkey:           pushNotificationToken,
			Data: struct {
				URL    string `json:"url"`
				Format string `json:"format`
			}{
				Format: "event_id_only",
				URL:    "https://push.ubports.com:5003/_matrix/push/v1/notify",
			},
			Append: false,
		}, nil)

		if err != nil {
			fmt.Println("Error registering notifications", err)
			return
		}

		err = files.CreateFile("/home/phablet/.local/share/nl.btr.element/element.txt", "1")
		if err != nil {
			fmt.Println("Error creating file", err)
			return
		}
	}
}

func GetQlient() (*QClient, error) {
	qClient := NewQClient(nil)
	return qClient, nil
}
