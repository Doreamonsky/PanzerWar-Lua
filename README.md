# 装甲纷争 Lua层逻辑
Lua 层 在装甲纷争中用于自定义模式与ui功能的编写，以及一些小功能的编写。此仓库为官方仓库，一些代码可供参考用于制作自己的mod,也可以为官方仓库贡献代码，为所有玩家提供新游戏功能。

## 开发最佳实践
建议使用 VS Code + EmmyLua 插件 进行lua代码的开发。 （EmmyLua 插件 需要 jdk 1.8） 游戏相关 api 接口查看文档 <https://www.waroftanks.cn/api/>. 此外，可查看 xlua 文档了解如何通过lua调用C#侧的代码。

## 代码测试
### Android 测试
代码编写完毕后，覆盖在 Android/data/com.ShanghaiWindy.PanzerWarDEM/files/HotFix

### PC 测试
PC 客户端暂未更新。

## 代码合并
方式一: Fork 修改后，提交 Pull Request。
方式二: 修改后的源码交付给我 QQ: 403036847

## 结构介绍
modes 文件夹下为游戏模式相关代码

