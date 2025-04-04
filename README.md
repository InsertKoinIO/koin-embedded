# Koin Embedded for Kotlin SDK & Library

Given that Android plugin doesn't allow to use external aar files anymore, and fatjar plugins are outdated ...
This project proposes scripts to help rebuild & package Koin project with a different package name. The interest is for <b>SDK & Library development</b>, to avoid conflict between embedded Koin version and any consuming application that would use another version of Koin, that might conflict.

Feedback or help? Contact [Koin Team](mailto:koin@kotzilla.io).


# Koin Relocation Scripts

## Setup

Open `relocate.properties` file to specify:
- RELOCATION_PREFIX - Prefix to relocate Koin package. "embedded", will transform `org.koin.*` to `embedded.koin.*`
- TARGET_KOIN_VERSION - Koin version tag to use
- KOIN_MODULES - list of Koin modules to rename with prefix. I.e `koin-core` will become `embeded-koin-core`
- BUILD_DIR - folder where Koin built artifacts are copied

### Exemple - Koin 3.5.6

```
RELOCATION_PREFIX=relocated
TARGET_KOIN_VERSION=3.5.6
KOIN_MODULES=core/koin-core;android/koin-android
BUILD_DIR=./build
```

### Exemple - Koin 4.0.4

```
RELOCATION_PREFIX=relocated
TARGET_KOIN_VERSION=4.0.4
KOIN_MODULES=core/koin-core;core/koin-core-viewmodel;android/koin-android
BUILD_DIR=./build
```

## Maven Repository

The file `repository.gradle` contains definition of a Maven repository. this definition will be injected into Koin, in order to publish artifacts on your repository.

This file is like below, edit it your your needs:
```
repositories {
    maven {
        name = "MyRepository"
        url = uri("https://repo.url.com")
        credentials {
            username = findProperty("USER")?.toString() ?: System.getenv("USER") ?: ""
            password = findProperty("PWD")?.toString() ?: System.getenv("PWD") ?: ""
        }
    }
}
```

## Run the Scripts

> Requirements: JDK 17 environment to build Koin project

Just run `./relocate.sh`. 

## Artifacts & Outputs

The output build will be in `./build` or $BUILD_DIR

Once executed, open the `./build` or $BUILD_DIR folder to get your aar/jar artifacts, to add to your project

All Koin modules will be installed locally, in your local Maven repo.

You can also run `publishAllPublicationsTo<Repo>Repository` (here below it would be `publishAllPublicationsToMyRepositoryRepository`), from `relocation/projects` folder, to publish your Koin modules to your repo. 

# Project Sample

The `embedded-project-sample` folder contains sample for Koin embedded SDK Library.

- sample-library - Android library project, using Koin embedded version in 3.5.6
- sample-app - Android Application using Koin 4.0.2 and sample-library

## Install Library

from `embedded-project-sample/sample-library` run `install.sh`

> This projects uses Kotzilla Koin Embedded repo.

## Run App & Library

from `embedded-project-sample/sample-app`, run the Android app


# Koin Embedded Version - Exemple

Here is an example of Koin embeded version: [Kotzilla Repository](https://repository.kotzilla.io/#browse/browse:Koin-Embedded) 
- Available packages: `embedded-koin-core`, `embedded-koin-android`
- Relocation on from `org.koin.*` to `embedded.koin.*`

Setupr your Gradle config with this Maven repository:
```kotlin
maven { 'https://repository.kotzilla.io/repository/kotzilla-platform/' }
```
