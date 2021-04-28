QT += core gui network widgets gamepad

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

HEADERS = $$files(cpp/*.h, true)
SOURCES = main.cpp
SOURCES += $$files(cpp/*.cpp, true)
FORMS = \
		res/forms/gamepad.ui \
		res/forms/monitor.ui
RESOURCES = resources.qrc
# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
	QT += androidextras

	ANDROID_PACKAGE_SOURCE_DIR = \
		$$PWD/android
	ANDROID_JAVA_SOURCES.path = $$PWD/android/src/inc/garage/periscope

	INSTALLS += ANDROID_JAVA_SOURCES

	DEFINES += APPLICATION_NAME=\\\"periscope\\\"
	DEFINES += ORGANIZATION_NAME=\\\"garage.inc\\\"

	DISTFILES += \
	android/AndroidManifest.xml \
	android/build.gradle \
	android/gradle/wrapper/gradle-wrapper.jar \
	android/gradle/wrapper/gradle-wrapper.properties \
	android/gradlew \
	android/gradlew.bat \
	android/res/values/libs.xml
}

