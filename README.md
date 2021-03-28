# fstreamer

A new Flutter project.

## Temporary fixes

- [x] android\src\main\kotlin\com\whelksoft\camera_with_rtmp\Camera.kt

```kotlin
sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION)!!
```

```kotlin
override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
    val surfaceTexture = flutterTexture.surfaceTexture()
    val size = getSizePairByOrientation()
    surfaceTexture.setDefaultBufferSize(size.first, size.second)
    val flutterSurface = Surface(surfaceTexture)
}

override fun surfaceDestroyed(holder: SurfaceHolder) {}
override fun surfaceCreated(holder: SurfaceHolder) {}
```

- [x] android\src\main\kotlin\com\whelksoft\camera_with_rtmp\CameraNativeView.kt

```kotlin
override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
    Log.d("CameraNativeView", "surfaceChanged $width $height")
}

override fun surfaceDestroyed(holder: SurfaceHolder) {
    Log.d("CameraNativeView", "surfaceDestroyed")
}
```

- [x] android\src\main\kotlin\com\whelksoft\camera_with_rtmp\CameraUtils.kt

```kotlin
details["sensorOrientation"] = sensorOrientation!!
```

- [x] android\src\main\kotlin\com\whelksoft\camera_with_rtmp\VideoEncoder.kt line 427:

```kotlin
processOutput(byteBuffer!!, mediaCodec, outBufferIndex, bufferInfo)
```
- [x] android\src\main\kotlin\com\whelksoft\camera_with_rtmp\VideoEncoder.kt line 218:

```kotlin
val byteBufferList = extractVpsSpsPpsFromH265(mediaFormat.getByteBuffer("csd-0")!!)
```