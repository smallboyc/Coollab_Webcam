#pragma once

#include <string>
#include <vector>
#include <thread>
#include <mutex>
#include <atomic>
#include <img/img.hpp>

namespace webcam
{
    struct Resolution
    {
        int width{1};
        int height{1};
        friend auto operator==(Resolution const &a, Resolution const &b) -> bool
        {
            return a.width == b.width && a.height == b.height;
        }
    };

    class UniqueId
    {
    private:
        std::string device_path;

    public:
        UniqueId() = default;
        explicit UniqueId(const std::string &val) : device_path(val) {}

        std::string getDevicePath() const { return device_path; }
    };

    struct Info
    {
        std::string name{}; /// Name that can be displayed in the UI
        std::vector<Resolution> available_resolutions{};
        std::vector<std::string> pixel_formats{};
        UniqueId unique_id{};
    };

    class Capture 
    {
    public:
        Capture(UniqueId unique_id)
            : _unique_id{unique_id}, _thread{[this]()
                                             { thread_job(*this); }}
        {
        }
        ~Capture()
        {
            stop_capture();
            if (_thread.joinable())
            {
                _thread.join();
            }
        }
        Capture(Capture const &) = delete;
        auto operator=(Capture const &) -> Capture & = delete;
        Capture(Capture &&) noexcept = delete;
        auto operator=(Capture &&) noexcept -> Capture & = delete;

        [[nodiscard]] auto has_stopped() const -> bool { return _has_stopped; }
        [[nodiscard]] auto unique_id() const -> UniqueId { return _unique_id; }
        [[nodiscard]] auto image() const -> img::Image;

    private:
        void thread_job(Capture &This);
        void stop_capture();

    private:
        std::mutex _mutex;
        std::optional<img::Image> _available_image;
        bool _has_stopped{false};
        UniqueId _unique_id;
        std::atomic<bool> _wants_to_stop_thread{false};
        std::thread _thread{};
    };

    std::vector<Info> getWebcamsInfo();

} // namespace webcam
