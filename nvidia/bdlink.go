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
	//"io"
	"io/ioutil"
	"os"
	//"os/exec"
	"regexp"
	"strconv"
	"strings"

	"github.com/elastic/beats/libbeat/common"
	"github.com/elastic/beats/libbeat/logp"
)

const (
	bdLinkPath = "/opt/bluedata/dev"
)

//BDLink_I provides interface to container name to GPU device links.
type BDLink_I interface {
	getBDDevLinks(linkPath string) ([]common.MapStr, error)
}

//BDLink implements one flavour of BDLink interface.
type BDLink struct {
}

//newBDLink returns instance of BDLink
func newBDLink() BDLink {
	return BDLink{}
}

func (g BDLink) getBDDevLinks(linkPath string) (map[int]string, error) {
	re := regexp.MustCompile(`\d+\z`)
	links := make(map[int]string)

	files, err := ioutil.ReadDir(linkPath)
	if err != nil {
		return nil, err
	}

	if len(files) == 0 {
		logp.Debug("nvidiagpubeat", "No links found")
		return nil, nil
	}

	for _, fileInfo := range files {
		if fileInfo.Mode()&os.ModeSymlink != 0 {
			fullLinkName := linkPath + "/" + fileInfo.Name()
			srcFileName, err := os.Readlink(fullLinkName)

			if err != nil {
				logp.Debug("nvidiagpubeat", "Error reading symbolic link %s: %s", fullLinkName, err.Error())
				continue
			}

			gpuNumStr := re.FindString(strings.TrimSpace(srcFileName))
			if len(gpuNumStr) == 0 {
				logp.Debug("nvidiagpubeat", "Bad formatted device name: %s", srcFileName)
				continue
			}
			gpuIndex, _ := strconv.Atoi(gpuNumStr)
			links[gpuIndex] = fileInfo.Name()
		}
	}

	return links, nil
}
