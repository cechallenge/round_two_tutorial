# CE Challenge Round 2 tutorial
CE Challenge round 2 tutorial 문서입니다.
<hr/>

## SSH 접속 가이드
사용하게 될 서버의 IP주소로 SSH을 사용하여 원격 접속을 시도합니다. 원격 접속을 위해 [Putty](https://www.putty.org/) 혹은 [MobaXterm](https://mobaxterm.mobatek.net/) 등 참가팀이 원하는 툴을 사용하시면 됩니다.
```
bash$) ssh <계정 아이디>@<IP주소>
```
## NVIDIA Toolkit install
Docker에서 NVIDIA GPU 사용을 위한 toolkit 설치가 필요합니다. 설치를 위한 가이드는 해당 [사이트](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)를 참조하여 설치 해주세요.

## CUDA Driver install
이번 대회에서 사용한 docker image와 호환되는 CUDA driver는 12.1입니다. 설치를 위한 가이드는 해당 [사이트](https://developer.nvidia.com/cuda-12-1-0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_local)를 참조하여 설치 해주세요.

## Docker setting
이번 대회 base docker image는 **nvcr.io/nvidia/pytorch:23.05-py3** 입니다.
이미지에 대한 자세한 사항 및 설명은 [link](https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/rel-23-05.html)을 참조 해주세요. 아래 명령어를 통해 Docker setting을 진행합니다.
```
bash$) chmod 755 docker_seeting.sh
bash$) ./docker_setting.sh
```
※ 스크립트 내의 docker container 실행을 위한 옵션은 변경하셔서 사용하시면 됩니다.

## Model & Dataset Download
2차 라운드에서 사용하게 될 모델은 LLaMA1-30B입니다. 해당 [link](https://huggingface.co/huggyllama/llama-30b)를 참고하여, 다운로드 진행 해주세요. Dataset은 [HellaSwag](https://huggingface.co/datasets/hellaswag) 입니다.

## Evaulation
### prerequisite
```
bash$) apt-get update
bash$) apt-get install bc
```

세팅을 마치신 후, evaluation code를 실행하여 Accuracy 및 Inference time을 확인하세요.
```
bash$) chmod 755 exec_evaluation.sh
bash$) ./exec_evaluation.sh
```
아래와 같은 Accuracy 및 Inference time이 출력되면 기본적인 세팅은 완료되었습니다.
