# 用于2026秋tny的超级拼装STG

这是东方天南宴关于东方Project主题修改版stg项目的重要源码，使用LuaSTG开发。本仓库用于保存当前实现；

## 内容

- LuaSTG AEX+ v0.8.22 的独立模组入口、关卡、Boss、弹幕与玩法实现。
- 包括所有已开发的符卡（当然，有多少要取决于项目的进度）及其他独立实验模组。
- scripts/ 下的准备工具、局部验证脚本和 SHA-256 文件清单 SOURCE_MANIFEST.json。

## 使用条件

此仓库是源码存档，不包含下载即玩的发行包。需要自行准备 LuaSTG AEX+ v0.8.22 及相应资源，按目录结构放入 aex-0.8.22/game；

模组资源不随本快照提供，部分脚本还依赖本地研究资料。缺少这些依赖时，模组和验证脚本不能独立运行。

请自行通过 LuaSTG 加载对应模组。注意，scripts/ 下部分验证脚本保留 G:\MySTG 的本地路径。

## 署名与开发中用到的AI辅助工具

- [SecretRenko](https://github.com/SecretRenko)
- ChatGPT（OpenAI）
- DeepSeek 
- 托管组织：东方天南宴（TouhouTiannanFeast）。
