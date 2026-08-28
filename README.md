# Engine issue 58 reproducer

This is a minimal Tuist-generated macOS app for [nathantannar4/Engine#58](https://github.com/nathantannar4/Engine/issues/58).

It pins the latest Engine release, 2.15.1, at revision 1d3f8229c51b808f0f224b84399739dfae5e50f6. The destination contains a toolbar tint probe that reads @Environment(\.tintStyle), alongside the custom ViewStyle chain from the related report.

## Build

From this directory:

~~~sh
tuist install
tuist generate --no-open
tuist xcodebuild build \
  -workspace EngineIssue58Repro.xcworkspace \
  -scheme EngineIssue58Repro-Workspace \
  -configuration Debug \
  -sdk macosx \
  -derivedDataPath .build/TuistDerivedData \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
~~~

The signing overrides keep this local diagnostic app buildable without a signing identity. The generated app is at:

~~~text
.build/TuistDerivedData/Build/Products/Debug/EngineIssue58Repro.app
~~~

Run it and click **Navigate to reproducer**, or let it navigate automatically:

~~~sh
/usr/bin/open -n -W \
  .build/TuistDerivedData/Build/Products/Debug/EngineIssue58Repro.app \
  --args --auto-trigger
~~~

On macOS 27.0 (26A5421a), Engine 2.15.1 reproduces:

~~~text
Fatal error: load from misaligned raw pointer
~~~

The crash stack includes PropertyList.ElementFieldsV8.Storage.element(offset:), keyType(offset:), and EnvironmentValues.tintStyle.getter. macOS uses .principal for the toolbar title-area placement; the linked iOS sample uses .title.
