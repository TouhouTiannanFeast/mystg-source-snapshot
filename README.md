# MySTG 源码冻结快照

这是东方天南宴组织下 MySTG 项目的重要源码快照，冻结日期为 2026-10-26。用于保存、阅读和研究当前实现；上传核验后将 GitHub 仓库归档为只读。

## 内容

- LuaSTG AEX+ v0.8.22 独立模组入口、关卡、Boss、弹幕与玩法实现。
- 包括 MySTG、Stage12Normal、Stage2Full、TH14Stage1Normal、MilkHoney、MamizouStage2、MystiaAya 系列及其他独立实验模组。
- scripts/ 下的准备工具、局部验证脚本和 SHA-256 文件清单 SOURCE_MANIFEST.json。

不包含 LuaSTG 运行程序、第三方框架整包、游戏原版程序、提取的图片/音乐资源、原始 ECL 文本、历史构建、缓存、日志、凭据和本地 Git 历史。早期 MLFD/MLforDanmu 自动生成实验未纳入本次重要源码选择。

## 使用条件

此仓库是源码存档，不是下载即玩的发行包。运行需要自行准备 LuaSTG AEX+ v0.8.22 及相应资源，按目录结构放入 aex-0.8.22/game；模组资源不随本快照提供，部分脚本还依赖本地研究资料。缺少这些依赖时，模组和验证脚本不能独立运行。

本快照不包含本地 CMD/PowerShell 启动器；请自行通过 LuaSTG 加载对应模组。scripts/ 下部分验证脚本保留 G:\MySTG 本地路径，使用前需核对。此快照仅验证文件复制一致性和上传范围，未重新执行游戏、完整构建或全部测试，也不宣称精确复现原作行为。

## 署名与来源

- [SecretRenko](https://github.com/SecretRenko)：项目发起、设计取舍、调试反馈与维护。
- ChatGPT（OpenAI）：协助实现、整理、验证和文档编写；属于 AI 协作署名。
- 托管组织：东方天南宴（TouhouTiannanFeast）。

东方 Project、LuaSTG 和其他第三方项目的权利归各自权利人。本快照保留源码中的来源信息；公开可见不代表第三方内容已获得额外授权。本次未新增统一开源许可，也未对第三方代码重新许可。


