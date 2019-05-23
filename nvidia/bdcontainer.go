//******************************************************************
//Copyright 2019 Hewlett Packard Corporation.
//Architect/Developer: Gernot Seidler

//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at

// https://www.apache.org/licenses/LICENSE-2.0

//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//******************************************************************

package nvidia

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net"
	"net/http"
	"regexp"
	"strings"
	"time"

	"github.com/elastic/beats/libbeat/logp"
)

const (
	sockPath = "/var/run/docker.sock"
)

func NewClient(sockPath string) *http.Client {
	t := &http.Transport{
		DialContext: func(_ context.Context, _, _ string) (net.Conn, error) {
			return net.Dial("unix", sockPath)
		},
	}
	timeout := time.Duration(5 * time.Second)
	return &http.Client{
		Transport: t,
		Timeout:   timeout,
	}
}

func GetContainerId(containerName string) string {
	if containerName == "" {
		return ""
	}

	url := fmt.Sprintf("http://localhost/containers/json?filters={\"name\":{\"%s\":true}}", containerName)
	client := NewClient(sockPath)
	resp, err := client.Get(url)
	if err != nil {
		logp.Err("nvidiagpubeat: %s", err)
		return ""
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	var result []map[string]interface{}

	err1 := json.Unmarshal(body, &result)
	if err1 != nil {
		logp.Err("nvidiagpubeat: %s", err1)
		return ""
	}

	re := regexp.MustCompile(fmt.Sprintf(`%s\z`, containerName))
	for i := 0; i < len(result); i++ {
		id := fmt.Sprintf("%v", result[i]["Id"])
		names := fmt.Sprintf("%v", result[i]["Names"])
		//logp.Debug("nvidiagpubeat", "Got Names=%s, Id=%s", names, id)
		if re.MatchString(strings.Trim(names, "[/]")) {
			logp.Debug("nvidiagpubeat", "Matched %s= %s, %s", containerName, names, id)
			return id
		}
	}

	return ""
}
