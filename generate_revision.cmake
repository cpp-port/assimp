cmake_minimum_required(VERSION 3.22)

if(NOT DEFINED ASSIMP_SOURCE_DIR OR NOT DEFINED REVISION_HEADER)
    message(FATAL_ERROR "ASSIMP_SOURCE_DIR and REVISION_HEADER are required")
endif()

file(READ "${ASSIMP_SOURCE_DIR}/CMakeLists.txt" assimp_cmake)
if(NOT assimp_cmake MATCHES "PROJECT\\([Aa]ssimp[ \t\r\n]+VERSION[ \t\r\n]+([0-9]+)\\.([0-9]+)\\.([0-9]+)")
    message(FATAL_ERROR "Cannot read the Assimp source version")
endif()
set(ASSIMP_VERSION_MAJOR "${CMAKE_MATCH_1}")
set(ASSIMP_VERSION_MINOR "${CMAKE_MATCH_2}")
set(ASSIMP_VERSION_PATCH "${CMAKE_MATCH_3}")
set(ASSIMP_PACKAGE_VERSION 0)

set(GIT_COMMIT_HASH 0)
set(GIT_BRANCH unknown)
find_package(Git QUIET)
if(GIT_FOUND)
    execute_process(COMMAND "${GIT_EXECUTABLE}" rev-parse HEAD
        WORKING_DIRECTORY "${ASSIMP_SOURCE_DIR}"
        RESULT_VARIABLE git_result OUTPUT_VARIABLE commit
        OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    if(git_result EQUAL 0 AND commit MATCHES "^[0-9a-fA-F]+$")
        # aiGetVersionRevision returns an unsigned int; keep exactly 32 bits.
        string(SUBSTRING "${commit}" 0 8 GIT_COMMIT_HASH)
        execute_process(COMMAND "${GIT_EXECUTABLE}" rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY "${ASSIMP_SOURCE_DIR}"
            RESULT_VARIABLE branch_result OUTPUT_VARIABLE branch
            OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
        if(branch_result EQUAL 0)
            string(REPLACE "\\" "\\\\" GIT_BRANCH "${branch}")
            string(REPLACE "\"" "\\\"" GIT_BRANCH "${GIT_BRANCH}")
        endif()
    endif()
endif()

set(CMAKE_SHARED_LIBRARY_PREFIX "")
set(LIBRARY_SUFFIX "")
set(CMAKE_DEBUG_POSTFIX "")
# The hand-maintained vcxproj uses the same DLL name for Debug and Release.
configure_file("${ASSIMP_SOURCE_DIR}/include/assimp/revision.h.in"
    "${REVISION_HEADER}" @ONLY NEWLINE_STYLE CRLF)
