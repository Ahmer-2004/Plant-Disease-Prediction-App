import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              weatherProvider.weatherData?.cityName ?? 'Weather Forecast',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            if (weatherProvider.weatherData != null)
              Text(
                'Forecast',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                if (weatherProvider.isLoading) {
                  return _buildLoadingState();
                }
                if (weatherProvider.error != null ||
                    weatherProvider.weatherData == null) {
                  return _buildErrorState(context, weatherProvider);
                }
                return _buildWeatherContent(context, weatherProvider.weatherData!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: _backgroundGradient(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
            const SizedBox(height: 16),
            Text(
              'Fetching weather data...',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WeatherProvider provider) {
    return Container(
      decoration: _backgroundGradient(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              'Weather data unavailable',
              style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enable location services',
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.fetchWeather(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Retry', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherData weather) {
    // Filter hourly to show only upcoming 24 hours
    final now = DateTime.now();
    final upcomingHourly = weather.hourlyForecast
        .where((h) => h.time.isAfter(now.subtract(const Duration(hours: 1))))
        .take(24)
        .toList();

    return Container(
      decoration: _backgroundGradient(),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // ── Current Weather Hero ──
                _buildCurrentWeatherHero(weather),
                const SizedBox(height: 28),

                // ── Hourly Forecast ──
                _buildSectionTitle('Hourly Forecast'),
                const SizedBox(height: 12),
                _buildHourlyForecast(upcomingHourly),
                const SizedBox(height: 28),

                // ── Daily Forecast ──
                _buildSectionTitle('${weather.dailyForecast.length}-Day Forecast'),
                const SizedBox(height: 12),
                _buildDailyForecast(weather.dailyForecast),
                const SizedBox(height: 28),

                // ── Detail Info Grid ──
                _buildSectionTitle('Weather Details'),
                const SizedBox(height: 12),
                _buildInfoGrid(weather),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Current Weather Hero ───

  Widget _buildCurrentWeatherHero(WeatherData weather) {
    final today = weather.dailyForecast.isNotEmpty ? weather.dailyForecast[0] : null;
    return Center(
      child: Column(
        children: [
          Icon(weather.getIcon(), size: 64, color: _iconColorForCode(weather.weatherCode)),
          const SizedBox(height: 12),
          Text(
            weather.cityName,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${weather.temperature.round()}°',
            style: GoogleFonts.outfit(
              fontSize: 80,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          Text(
            weather.condition,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          if (today != null)
            Text(
              '${today.temperatureMin.round()}° / ${today.temperatureMax.round()}°',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white60,
              ),
            ),
        ],
      ),
    );
  }

  // ─── Hourly Forecast ───

  Widget _buildHourlyForecast(List<HourlyWeather> hourly) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: hourly.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final h = hourly[index];
          final isNow = index == 0;
          return _GlassCard(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            highlight: isNow,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isNow ? 'Now' : '${h.time.hour.toString().padLeft(2, '0')}:00',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isNow ? FontWeight.bold : FontWeight.w500,
                    color: isNow ? Colors.greenAccent : Colors.white70,
                  ),
                ),
                Icon(h.getIcon(), size: 24, color: _iconColorForCode(h.weatherCode)),
                Text(
                  '${h.temperature.round()}°',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Daily Forecast ───

  Widget _buildDailyForecast(List<DailyWeather> daily) {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: List.generate(daily.length, (index) {
          final d = daily[index];
          final isToday = index == 0;
          return Column(
            children: [
              if (index > 0)
                Divider(color: Colors.white.withOpacity(0.08), height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    // Date
                    SizedBox(
                      width: 44,
                      child: Text(
                        d.formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                    // Day name
                    SizedBox(
                      width: 40,
                      child: Text(
                        isToday ? 'Today' : d.dayName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday ? Colors.greenAccent : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Weather icon
                    Icon(d.getIcon(), size: 22, color: _iconColorForCode(d.weatherCode)),
                    // Rain probability
                    if (d.precipitationProbabilityMax > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${d.precipitationProbabilityMax}%',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.lightBlueAccent.withOpacity(0.8),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Min / Max
                    Text(
                      '${d.temperatureMin.round()}°',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Temp bar
                    _buildTempBar(d.temperatureMin, d.temperatureMax, daily),
                    const SizedBox(width: 4),
                    Text(
                      '${d.temperatureMax.round()}°',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTempBar(double min, double max, List<DailyWeather> allDays) {
    // Normalize against global forecast range
    double globalMin = allDays.map((d) => d.temperatureMin).reduce((a, b) => a < b ? a : b);
    double globalMax = allDays.map((d) => d.temperatureMax).reduce((a, b) => a > b ? a : b);
    double range = globalMax - globalMin;
    if (range == 0) range = 1;

    double startFrac = (min - globalMin) / range;
    double endFrac = (max - globalMin) / range;

    return SizedBox(
      width: 70,
      height: 6,
      child: CustomPaint(
        painter: _TempBarPainter(startFrac, endFrac),
      ),
    );
  }

  // ─── Info Grid ───

  Widget _buildInfoGrid(WeatherData weather) {
    final today = weather.dailyForecast.isNotEmpty ? weather.dailyForecast[0] : null;

    String formatSunTime(String isoTime) {
      try {
        final dt = DateTime.parse(isoTime);
        final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
      } catch (_) {
        return isoTime;
      }
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                icon: Icons.water_drop_outlined,
                value: '${weather.humidity}%',
                label: 'Humidity',
                iconColor: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                icon: Icons.thermostat_outlined,
                value: '${weather.feelsLike.round()}°',
                label: 'Feels Like',
                iconColor: Colors.orangeAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                icon: Icons.wb_sunny_outlined,
                value: today != null ? '${today.uvIndexMax.round()}' : '--',
                label: 'UV Index',
                iconColor: Colors.amberAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                icon: Icons.air_rounded,
                value: '${weather.windSpeed.round()} km/h',
                label: 'Wind',
                iconColor: Colors.tealAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                icon: Icons.wb_twilight_rounded,
                value: today != null ? formatSunTime(today.sunrise) : '--',
                label: 'Sunrise',
                iconColor: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                icon: Icons.nights_stay_outlined,
                value: today != null ? formatSunTime(today.sunset) : '--',
                label: 'Sunset',
                iconColor: Colors.deepPurpleAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoTile(
                icon: Icons.umbrella_outlined,
                value: today != null ? '${today.precipitationProbabilityMax}%' : '--',
                label: 'Rain Chance',
                iconColor: Colors.indigoAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoTile(
                icon: Icons.visibility_outlined,
                value: weather.condition,
                label: 'Condition',
                iconColor: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  BoxDecoration _backgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E3C2F),
          Color(0xFF2E7D32),
          Color(0xFF1B5E20),
          Color(0xFF0D3B1F),
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
      ),
    );
  }

  Color _iconColorForCode(int code) {
    if (code == 0) return Colors.amber;
    if (code >= 1 && code <= 3) return Colors.white70;
    if (code == 45 || code == 48) return Colors.blueGrey;
    if (code >= 51 && code <= 67) return Colors.lightBlueAccent;
    if (code >= 71 && code <= 77) return Colors.white;
    if (code >= 80 && code <= 82) return Colors.lightBlueAccent;
    if (code >= 95) return Colors.yellowAccent;
    return Colors.white70;
  }
}

// ─── Reusable Glass Card ───

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final bool highlight;

  const _GlassCard({
    required this.child,
    required this.padding,
    this.width,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: highlight
                ? Colors.greenAccent.withOpacity(0.12)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: highlight
                  ? Colors.greenAccent.withOpacity(0.3)
                  : Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Custom Painter for temperature range bar ───

class _TempBarPainter extends CustomPainter {
  final double startFrac;
  final double endFrac;

  _TempBarPainter(this.startFrac, this.endFrac);

  @override
  void paint(Canvas canvas, Size size) {
    // Background track
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(3),
      ),
      bgPaint,
    );

    // Active bar with gradient
    final barRect = Rect.fromLTWH(
      size.width * startFrac,
      0,
      size.width * (endFrac - startFrac),
      size.height,
    );
    final gradient = LinearGradient(
      colors: [Colors.lightBlueAccent, Colors.amber, Colors.deepOrange],
    );
    final barPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(3)),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
