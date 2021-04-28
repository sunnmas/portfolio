#include "../headers/telemetry.h"

Telemetry::Telemetry() {}

TelemetryStruct *Telemetry::read() {
	telemetry.charge = 99;
    telemetry.deep = 13.26;
    return &telemetry;
}