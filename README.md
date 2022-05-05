# Internet-project
sdram,ov5640,vga,sobel,uart,etc..

## 描述
该项目实现了由OV5640摄像头读取图像到FPGA的sdram中，再进行sobel边缘检测，刻度识别，最后将rgb565格式的图像数据转换成base64的格式并将其转换成json串，以uart通信的方式传送给
4G芯片CAT1，由它发送给云端

## 文件说明
* 老版代码：[v1.0]()
* 新版代码：[v2.0]()
* mypart：实现2byte to 480byte的转换，rgb565到base64的转换，uart通信模块，形成json串 [transform_uart_iot]()
