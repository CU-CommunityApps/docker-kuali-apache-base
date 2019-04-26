# Docker configuration for Apache 2.4 image

This image is built upon [CU-CommunityApps/docker-base](https://github.com/CU-CommunityApps/docker-base), which essentially includes packages from Ubuntu 14.04.5 LTS.


# Building the image

The included `bin/go.sh` script will run through building mod_cuwebauth.so, creating the image and running a basic set of tests on the result.  Two environment variables are required to be set:

 - **CUWA_VERSION** -- The version of CUWebAuth being built (ie: 2.3.0.238)
 - **DOCKER_IMG** -- The label for the resulting Docker image (ie: dtr.cucloud.net/cs/apache24)

Prior to running `go.sh`, you need to obtain a copy of the CUWebAuth source code from Identity Management and place it in the `cuwal-src/` directory (ie: `cuwal-src/cuwal-${CUWA_VERSION}.tar.gz`).  


# Test suite

As part of running an image build via `bin/go.sh`, a series of quick validation tests are performed on the new image before exiting cleanly.  This is accomplished by giving the new image a specific tag (`:test-build`) and launching the image as a new Docker container so we can run `bin/run-tests.sh`.

The tests performed in `bin/run-tests.sh` are fairly basic but include:

 - Ensuring Apache can load `mod_cuwebauth.so`.
 - Ensuring Apache fails to start with `mod_cuwebauth` in play but no proper configuration.
 - Testing enabling and disabling Apache modules.
 - Testing basic index page load.
 - Verifying requests for CUWebAuth-secured content are being redirected to the weblogin servers.

Any test failures should result in a non-zero exit from both `run-tests.sh` and `go.sh`.  By not tagging the image with the default `latest` indicator, any attempt to push the image downstream should fail (or result in a re-push of a previous version).  To be sure, always check the exit code from `go.sh` before moving on with your image publishing processes.


# Building mod_cuwebauth

When running `bin/go.sh`, we automatically attempt to build `lib/mod_cuwebauth.so` in the same environment used to run Apache.  Instead of baking a shared object file into this repository, we purposely take this step to ensure CUWebAuth is compiled natively in the environment as external dependencies change.  The `.gitignore` file is purposely ignoring everything unser `lib/`; we should **not** be distributing pre-compiled binaries or CUWebAuth sources with this repository!

The included `bin/build-mod_cuwebauth.sh` script can be used to compile mod_cuwebauth within a Docker container.  The script will build a temporary Docker image, copy the mod_cuwebauth.so artifact to `lib/` and clean up the temporary images/containers.

```
./bin/build-mod_cuwebauth.sh
```

The `build-mod_cuwebauth.sh` script requires environment variables **CUWA_VERSION** and **DOCKER_IMG** to be set.  The corresponding source tarball _must_ exist in the `cuwal-src/` directory.  We do not distribute the CUWebAuth sources with this repository; you will need to obtain them from Identity Management prior to launching a build.  Also consider where alterations to the compilation enviromnment or CUWA sources are required when updating versions.


# CUWA Compiliation issues

In the `cuwal-src/` tree, there exists a patch for the bundled `configure` script for cuwal-2.3.0.238.  The stock `configure` script gets stuck trying to probe for `apr_psprintf()`; this patch simply bypasses that probe.

There also exists a patch for `/usr/share/apache2/build/config_vars.mk` on Ubuntu 14.04.  The included APXS version adds CFLAGS that treat `format-security` compiler warnings as _errors_, interrupting the build of `mod_cuwebauth.la`.  While this does not impact the shared object generation, the patch removes that warning as an error and allows the build to complete.

In time, we should circle back around with Identity Management to see if they are aware of these issues.
