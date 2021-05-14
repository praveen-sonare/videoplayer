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
#include <QtQml/QQmlApplicationEngine>
#include <QtGui/QGuiApplication>
#include <QDebug>
#include <QUrlQuery>
#include <QCommandLineParser>
#include <QtQml/QQmlContext>


int main(int argc, char *argv[])
{
	
	setenv("QT_QPA_PLATFORM", "wayland", 1);
	int port;
	QString token;
	
	QCommandLineParser parser;
	QGuiApplication app(argc, argv);

	parser.addPositionalArgument("port",
		app.translate("main", "port for binding"));
	parser.addPositionalArgument("secret",
		app.translate("main", "secret for binding"));

	parser.addHelpOption();
	parser.addVersionOption();
	parser.process(app);
	QStringList positionalArguments = parser.positionalArguments();

	if (positionalArguments.length() == 2) {
		port = positionalArguments.takeFirst().toInt();
		token = positionalArguments.takeFirst();
		qInfo() << "setting port:" << port << ", token:" << token;
	} else {
		qInfo() << "Need to specify port and token";
		exit(EXIT_FAILURE);
	}
	
	QUrl bindingAddress;
	bindingAddress.setScheme(QStringLiteral("ws"));
	bindingAddress.setHost(QStringLiteral("localhost"));
	bindingAddress.setPort(port);
	bindingAddress.setPath(QStringLiteral("/api"));

	QUrlQuery query;
	query.addQueryItem(QStringLiteral("token"), token);
	bindingAddress.setQuery(query);

	QQmlApplicationEngine engine;
	engine.rootContext()->setContextProperty(QStringLiteral("bindingAddress"), bindingAddress);
	engine.load(QUrl(QStringLiteral("qrc:/VideoPlayer.qml")));

	return app.exec();
	
}
