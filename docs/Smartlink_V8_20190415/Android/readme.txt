v8.3.1： 
去掉了hiflying-iots-android-smartlink-x.x.x.jar的混淆。

v8.3.0: 1.增加对机智云自定义用户数据前缀0x00 0x1B的支持，2.增加<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"></uses-permission>以避免android9+上无法获得wifi ssid

v8.2.0:
更新支持HF-LPD100

v8.1.0:
修复小部分安卓手机代码中API获取子网掩码失败，导致最终配网失败。

MulticastSmartLinker.getInstance()
v8.0.1:
修正当客户未设置自定义用户信息或设置自定义用户信息为null时的异常

