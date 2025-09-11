import { useState } from "react";
import { Plus, Edit, Trash2, Clock, Calendar } from "lucide-react";

export default function Schedule() {
  const [schedules] = useState([
    {
      id: "1",
      name: "Jadwal Standar",
      startTime: "08:00",
      endTime: "17:00",
      breakStartTime: "12:00",
      breakEndTime: "13:00",
      isActive: true,
    },
    {
      id: "2",
      name: "Jadwal Fleksibel",
      startTime: "09:00",
      endTime: "18:00",
      breakStartTime: "12:30",
      breakEndTime: "13:30",
      isActive: false,
    },
  ]);

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Jadwal Kerja</h1>
          <p className="text-gray-600">
            Kelola jadwal kerja dan jam operasional
          </p>
        </div>
        <button className="btn-primary flex items-center">
          <Plus className="h-4 w-4 mr-2" />
          Tambah Jadwal
        </button>
      </div>

      {/* Current schedule info */}
      <div className="card">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Jadwal Aktif
        </h3>
        <div className="bg-primary-50 border border-primary-200 rounded-lg p-4">
          <div className="flex items-center">
            <Calendar className="h-5 w-5 text-primary-600 mr-2" />
            <span className="font-medium text-primary-900">Jadwal Standar</span>
          </div>
          <div className="mt-2 text-sm text-primary-700">
            <p>Jam Masuk: 08:00 - Jam Pulang: 17:00</p>
            <p>Jam Istirahat: 12:00 - 13:00</p>
          </div>
        </div>
      </div>

      {/* Schedule list */}
      <div className="card">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          Daftar Jadwal
        </h3>
        <div className="space-y-4">
          {schedules.map((schedule) => (
            <div
              key={schedule.id}
              className="border border-gray-200 rounded-lg p-4"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <Clock className="h-5 w-5 text-gray-400 mr-3" />
                  <div>
                    <h4 className="font-medium text-gray-900">
                      {schedule.name}
                    </h4>
                    <p className="text-sm text-gray-600">
                      {schedule.startTime} - {schedule.endTime}
                      {schedule.breakStartTime && (
                        <span>
                          {" "}
                          (Istirahat: {schedule.breakStartTime} -{" "}
                          {schedule.breakEndTime})
                        </span>
                      )}
                    </p>
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <span
                    className={`inline-flex px-2 py-1 text-xs font-medium rounded-full ${
                      schedule.isActive
                        ? "bg-success-100 text-success-800"
                        : "bg-gray-100 text-gray-800"
                    }`}
                  >
                    {schedule.isActive ? "Aktif" : "Tidak Aktif"}
                  </span>
                  <button className="text-gray-600 hover:text-gray-900">
                    <Edit className="h-4 w-4" />
                  </button>
                  <button className="text-danger-600 hover:text-danger-900">
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
