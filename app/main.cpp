/*
 * Copyright (C) 2018 The Qt Company Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// #include <QtAGLExtras/AGLApplication>
#include <QtQml/qqml.h>
#include <qlibwindowmanager.h>
#include <QQuickWindow>
#include <QtCore/QCommandLineParser>
#include <QtCore/QDebug>
#include <QtCore/QDir>
#include <QtCore/QStandardPaths>
#include <QtCore/QUrlQuery>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuickControls2/QQuickStyle>
#include <libhomescreen.hpp>

int main(int argc, char* argv[]) {
    // AGLApplication app(argc, argv);
    // app.setApplicationName("VideoPlayer");
    // app.setupApplicationRole("Video");
    // app.load(QUrl(QStringLiteral("qrc:/VideoPlayer.qml")));
    // return app.exec();

    QString role = QString("Video");
    QGuiApplication app(argc, argv);

    app.setApplicationName("VideoPlayer");

    QQuickStyle::setStyle("AGL");

    QQmlApplicationEngine engine;
    QQmlContext* context = engine.rootContext();

    QCommandLineParser parser;
    parser.addPositionalArgument("port",
                                 app.translate("main", "port for binding"));
    parser.addPositionalArgument("secret",
                                 app.translate("main", "secret for binding"));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.process(app);
    QStringList positionalArguments = parser.positionalArguments();

    if (positionalArguments.length() == 2) {
        int port = positionalArguments.takeFirst().toInt();
        QString secret = positionalArguments.takeFirst();
        QUrl bindingAddress;
        bindingAddress.setScheme(QStringLiteral("ws"));
        bindingAddress.setHost(QStringLiteral("localhost"));
        bindingAddress.setPort(port);
        bindingAddress.setPath(QStringLiteral("/api"));
        QUrlQuery query;
        query.addQueryItem(QStringLiteral("token"), secret);
        bindingAddress.setQuery(query);
        context->setContextProperty(QStringLiteral("bindingAddress"),
                                    bindingAddress);
        std::string token = secret.toStdString();
        LibHomeScreen* hs = new LibHomeScreen();
        QLibWindowmanager* qwm = new QLibWindowmanager();

        QString area;

        // WindowManager
        if (qwm->init(port, secret) != 0) {
            exit(EXIT_FAILURE);
        }
        // Request a surface as described in layers.json windowmanager’s file
        if (qwm->requestSurface(role) != 0) {
            exit(EXIT_FAILURE);
        }

        engine.load(QUrl(QStringLiteral("qrc:/VideoPlayer.qml")));
        QObject* root = engine.rootObjects().first();

        // Create an event callback against an event type. Here a lambda is
        // called when SyncDraw event occurs
        qwm->set_event_handler(
            QLibWindowmanager::Event_SyncDraw,
            [qwm, role, &area, root](json_object* object) {
                fprintf(stderr, "Surface got syncDraw!\n");

                // get area
                json_object* areaJ = nullptr;
                if (json_object_object_get_ex(object, "drawing_area", &areaJ)) {
                    area = QLatin1String(json_object_get_string(areaJ));

                    QMetaObject::invokeMethod(root, "changeArea",
                                              Q_ARG(QVariant, area));
                }

                qwm->endDraw(role);
            });

        // HomeScreen
        hs->init(port, token.c_str());
        // Set the event handler for Event_TapShortcut which will activate the
        // surface for windowmanager
        hs->set_event_handler(
            LibHomeScreen::Event_TapShortcut, [qwm, role](json_object* object) {
                qDebug("Surface Video got tapShortcut\n");
                struct json_object *obj_param = nullptr, *obj_area = nullptr;
                if(json_object_object_get_ex(object, "parameter", &obj_param)
                && json_object_object_get_ex(obj_param, "area", &obj_area)) {
                    qwm->activateWindow(role, json_object_get_string(obj_area));
                }
                else {
                    qwm->activateWindow(role, "normal");
                }
            });

        // Set the event handler for Event_Restriction which will allocate or
        // release restriction area for homescreen
        qwm->set_event_handler(
            QLibWindowmanager::Event_LightstatusBrakeOff,
            [hs, &area](json_object* object) {
                qDebug() << "Event_LightstatusBrakeOff!";
                hs->allocateRestriction(area.toStdString().c_str());
            });

        qwm->set_event_handler(
            QLibWindowmanager::Event_LightstatusBrakeOn,
            [hs, &area](json_object* object) {
                qDebug() << "Event_LightstatusBrakeOn!";
                hs->releaseRestriction(area.toStdString().c_str());
            });

        QQuickWindow* window = qobject_cast<QQuickWindow*>(root);
        QObject::connect(window, SIGNAL(frameSwapped()), qwm,
                         SLOT(slotActivateSurface()));
    }
    return app.exec();
}
