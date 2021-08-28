# Blotter Docker

在 Docker 中 **无脑地** 运行 Blotter 博客

相关项目:
- [后端 OhYee/blotter](https://github.com/OhYee/blotter)
- [前端 OhYee/blotter_page](https://github.com/OhYee/blotter_page)

## 使用

```bash
# 拉取最新版镜像
bash script.bash pull

# 启动服务
bash script.bash start

# 关闭服务
bash script.bash stop
```
## TODO

- [x] Docker 编译镜像
- [x] Docker 运行博客
- [ ] 自动初始化数据库
- [ ] 定时任务脚本自动配置
- [ ] 完善文档
- [ ] 自动部署

## 公网访问

默认监听 50000 端口，同时在 80 端口监听 www.example.com 域名，可配置 nginx/conf.d 相关文件修改域名及 HTTPS