# applies Qt specific configuration
# for GUI applications, QtGuiAppConfig must be included before
# after including this module, AppTarget must be included

# add the Core module as it is always required
# also add additional Qt/KF modules which must have been specified before if required
# the Gui/Widgets/Quick modules should be added by including QtGuiAppConfig
set(QT_MODULES Core ${ADDITIONAL_QT_MODULES})
set(KF_MODULES ${ADDITIONAL_KF_MODULES})

# enable lrelease and add install target for localization
if(TS_FILES)
    message(STATUS "Project has translations which will be released.")

    # the LinguistTools module is required
    # (but not add it to QT_MODULES because we don't link against it)
    find_package(Qt5LinguistTools REQUIRED)

    # adds the translations and a target for it
    qt5_add_translation(QM_FILES ${TS_FILES})
    add_custom_target(${META_PROJECT_NAME}_translations ALL DEPENDS ${QM_FILES})

    # add installs and install target for translations
    install(FILES ${QM_FILES}
        DESTINATION share/${META_PROJECT_NAME}/translations
        COMPONENT localization
    )
    if(NOT TARGET install-localization)
        set(LOCALIZATION_TARGET "install-localization")
        add_custom_target(${LOCALIZATION_TARGET}
            DEPENDS ${META_PROJECT_NAME}_translations
            COMMAND "${CMAKE_COMMAND}" -DCMAKE_INSTALL_COMPONENT=localization -P "${CMAKE_BINARY_DIR}/cmake_install.cmake"
        )
    endif()
endif()

# check whether D-Bus interfaces need to be processed
if(DBUS_FILES)
    message(STATUS "Project has D-Bus interface declarations which will be processed.")
    # the D-Bus Qt module is required
    list(APPEND QT_MODULES DBus)
endif()

# actually find the required Qt/KF modules
foreach(QT_MODULE ${QT_MODULES})
    find_package(Qt5${QT_MODULE} REQUIRED)
    list(APPEND LIBRARIES Qt5::${QT_MODULE})
endforeach()

foreach(KF_MODULE ${KF_MODULES})
    find_package(KF5${KF_MODULE} REQUIRED)
    list(APPEND LIBRARIES KF5::${KF_MODULE})
endforeach()

# generate DBus interfaces
if(DBUS_FILES)
    qt5_add_dbus_interfaces(SRC_FILES ${DBUS_FILES})
endif()

# enable moc, uic and rcc
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
if(${WIDGETS_GUI} STREQUAL "yes")
    set(CMAKE_AUTOUIC ON)
endif()
