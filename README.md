# AJMP
PhotoKit（iOS8.0及以上）实现相册媒体资源的主流操作（模仿微博的图片选择器），功能：图片选择、视频选择、单图裁剪。

AJMediaPicker（简称AJMP）的结构组成：
（1）MediaPicker：通过PhotoKit获取图片、视频等媒体资源，并选择用户需要的图片或视频。
（2）ImageCropper：实现单图裁剪功能。
（3）MediaPreviewer：图片、视频等媒体资源的预览器。
（4）AuthorizationTool：相册、相机的授权工具，判断相册、相机是否授权，并定义了未授权的页面。
（5）MediaSaveTool：媒体资源的保存工具，将图片、视频等媒体资源保存到系统相册，并自定义与工程名一致的相册。
