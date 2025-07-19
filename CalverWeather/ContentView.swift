
import SwiftUI
import Foundation

struct CurrentModel: Codable {
    let Temperature: Temperature
    let WeatherText: String
    let EpochTime: Int
    
    struct Temperature: Codable {
        struct Metric: Codable {
            let Value: Decimal
        }
        let Metric: Metric
        struct Imperial: Codable {
            let Value: Decimal
        }
        let Imperial: Imperial
    }
}

struct ForecastModel: Codable {
    struct Headline: Codable {
        let Text: String
    }
    let Headline: Headline
    
    struct DailyForecast: Codable {
        let EpochDate: Int
        struct Temperature: Codable {
            struct Minimum: Codable {
                let Value: Decimal
            }
            struct Maximum: Codable {
                let Value: Decimal
            }
            let Minimum: Minimum
            let Maximum: Maximum
        }
        let Temperature: Temperature
        
        struct Day: Codable {
            let IconPhrase: String
        }
        struct Night: Codable {
            let IconPhrase: String
        }
        let Day: Day
        let Night: Night
    }
    let DailyForecasts: [DailyForecast]
}

struct DailyTwelveHourForecast: Codable {
    let EpochDateTime: Int
    let IconPhrase: String
    
    struct Temperature: Codable {
        let Value: Decimal
    }
    let Temperature: Temperature
}

struct ContentView: View {
    @State var currents: [CurrentModel] = []
    @State var twelveHourForecasts: [DailyTwelveHourForecast] = []
    @State var forecast: ForecastModel?
    @State var lastUpdated: String = ""
    @State var minTemp: Decimal = 0
    @State var maxTemp: Decimal = 0
    @State private var taskIsComplete = false   // for haptics
    
    @AppStorage("tapCount") private var tapCount = 0   //for tapcount
    @AppStorage("isMetric") private var isMetric = true
    
    
    var body: some View {
        ZStack {
            
            VStack {
//                Spacer()
                Image(systemName: "baseball.diamond.bases")
                    .font(.system(size: 160))
                    .foregroundStyle(.red)
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                
                Text("Calver Weather App")
                //                     .foregroundStyle(.black)
                    .font(.system(size: 28))
                //                    .preferredColorScheme(.light)
                
                if(isMetric) {
                    Text(currents.isEmpty ? "" : "\(currents[0].Temperature.Metric.Value)°C")
                        .font(.system(size: 56))
                } else {
                    Text(currents.isEmpty ? "" : "\(currents[0].Temperature.Imperial.Value)°F")
                        .font(.system(size: 56))
                }
                
                Text(currents.isEmpty ? "" : "\(currents[0].WeatherText)")
                    .font(.system(size: 26))
                
                if(isMetric){
                    Text(forecast?.DailyForecasts.isEmpty ?? true ? "" : " High:\(maxTemp) °C")
                        .font(.system(size: 18))
                    Text(minTemp == 0 ? "" : "Min:\(String(format: "%.1f", NSDecimalNumber(decimal: minTemp).doubleValue)) °C")
                        .font(.system(size: 20))
                } else {
                    
                    Text(forecast?.DailyForecasts.isEmpty ?? true ? "" : " High:\(String(format: "%.1f", NSDecimalNumber(decimal: maxTemp * 1.8 + 32).doubleValue)) °F")
                        .font(.system(size: 18))
                    Text(minTemp == 0 ? "" : "Min:\(String(format: "%.1f", NSDecimalNumber(decimal: minTemp * 1.8 + 32).doubleValue)) °F")
                        .font(.system(size: 20))
                }
                
                Toggle(isOn: $isMetric) {
                    Text("Metric")
                }
                .font(.system(size: 18))
                .frame(width: 115, height: 20, alignment: .center)
                .padding(.top, 10)
                //            Button("Tap count: \(tapCount)") {
                //                        tapCount += 1
                //                    }
                
//                Spacer()
                
                Text("Current Conditions:")
                    .padding(.top, 10)
                
                if let headline = forecast?.Headline.Text {
                    Text(headline)
                        .font(.system(size: 16))
                        .padding(.bottom, 5)
                } else {
                    Text("No forecast available")
                        .font(.system(size: 16))
                        .padding(.bottom, 5)
                }
                
                Text("Hourly Forecast:")
                    .font(.system(size: 16))
                    .padding(.bottom, -5)
                
                // Hourly Forecast ScrollView
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(twelveHourForecasts, id: \.EpochDateTime) { forecast in
                            VStack {
                                let date = Date(timeIntervalSince1970: TimeInterval(forecast.EpochDateTime))
                                Text(date, style: .time)
                                    .font(.system(size: 14))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white)
                                    .padding(.top, 2)
                                Text(isMetric
                                    ? "\(String(format: "%.1f", NSDecimalNumber(decimal: forecast.Temperature.Value).doubleValue))°C"
                                    : "\(String(format: "%.1f", NSDecimalNumber(decimal: forecast.Temperature.Value * 1.8 + 32).doubleValue))°F"
                                )
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.white)
                                Text(forecast.IconPhrase)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.white)
                            }
                            .frame(width: 250, height: 60)
                            .background(Color("AccentColor"))
                            .cornerRadius(8)
                        }
                    }
                    .scrollTargetLayout()
                }
                .frame(width: 250, height: 100)
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.leading, 0)
                .scrollIndicators(.hidden)
                .padding(.bottom, -20)
                .padding(.top, -20)
                
                Text("Daily Forecast:")
                    .font(.system(size: 16))
                    .padding(.bottom, -15)
                
                // Daily Forecast ScrollView
                ScrollView(.horizontal) {
                    LazyHStack {
                        if let dailyForecasts = forecast?.DailyForecasts {
                            ForEach(0..<dailyForecasts.count, id: \.self) { index in
                                let day = dailyForecasts[index]
                                let date = Date(timeIntervalSince1970: TimeInterval(day.EpochDate))
                                var formatter: DateFormatter {
                                    let f = DateFormatter()
                                    f.dateFormat = "EEEE"
                                    return f
                                }
                                VStack(alignment: .leading) {
                                    Text(formatter.string(from: date))
                                        .font(.system(size: 16))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Day: \(day.Day.IconPhrase)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                    Text("Night: \(day.Night.IconPhrase)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                    Text(isMetric
                                        ? "Min: \(String(format: "%.1f", NSDecimalNumber(decimal: day.Temperature.Minimum.Value).doubleValue))°C"
                                        : "Min: \(String(format: "%.1f", NSDecimalNumber(decimal: day.Temperature.Minimum.Value * 1.8 + 32).doubleValue))°F"
                                    )
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                    Text(isMetric
                                        ? "Max: \(String(format: "%.1f", NSDecimalNumber(decimal: day.Temperature.Maximum.Value).doubleValue))°C"
                                        : "Max: \(String(format: "%.1f", NSDecimalNumber(decimal: day.Temperature.Maximum.Value * 1.8 + 32).doubleValue))°F"
                                    )
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 250, height: 100)
                                .background(Color("AccentColor"))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .frame(width: 250, height: 120)
                .scrollTargetBehavior(.viewAligned)
                .safeAreaPadding(.leading, 0)
                .scrollIndicators(.hidden)
                Spacer()
                Button("Refresh Data") {
                    taskIsComplete = true
                    grabCurrentData()
                    grabForecastData()
                    grabTwelveHour()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentColor"))
                .sensoryFeedback(.success, trigger: taskIsComplete)
                HStack {
                    Text("Last API update:")
                        .font(.system(size: 16))
                    Text(lastUpdated)
                        .font(.system(size: 16))
                }
            }
            .task {
                grabCurrentData()
                grabForecastData()
                grabTwelveHour()
            }
        }
    }
    
    
    
    
    
    
    
    
    func grabCurrentData() {
        Task {
            do {
                
                let url = URL(string: "https://dataservice.accuweather.com/currentconditions/v1/55489?apikey=\(APIKeys.accuweather)")
                let (data, response) = try await URLSession.shared.data(
                    from: url!
                )
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        print("CurrentGood")
                        print(response.statusCode)
                    } else {
                        print("CurrentBad")
                        print(response.statusCode)
                    }
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                currents = try decoder.decode([CurrentModel].self, from: data)
                if let epoch = currents.first?.EpochTime {
                    let date = Date(timeIntervalSince1970: TimeInterval(epoch))
                    let formatter = DateFormatter()
                    formatter.timeStyle = .short
                    formatter.dateStyle = .none
                    lastUpdated = formatter.string(from: date)
                }
                //                print(currents)
                //                print(lastUpdated)
            } catch {
                //                currents = []
            }
        }
    }
    func grabTwelveHour() {
        Task {
            do {
                let url = URL(string: "https://dataservice.accuweather.com/forecasts/v1/hourly/12hour/55489?apikey=Qc1ej31WWglKsRnGyRNbRjA5atq9ei1H&details=true&metric=true")
                let (data, response) = try await URLSession.shared.data(
                    from: url!
                )
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        print("TwelveHour Good")
                        print(response.statusCode)
                    } else {
                        print("TwelveHour Bad")
                        print(response.statusCode)
                    }
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                twelveHourForecasts = try decoder.decode([DailyTwelveHourForecast].self, from: data)
                
                //                print(twelveHourForecasts)
                
            } catch {
                //                currents = []
            }
        }
    }
    func grabForecastData() {
        Task {
            do {
                let url = URL(string: "https://dataservice.accuweather.com/forecasts/v1/daily/5day/55489?apikey=Qc1ej31WWglKsRnGyRNbRjA5atq9ei1H&metric=true")
                let (data, response) = try await URLSession.shared.data(
                    from: url!
                )
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        print("ForecastGood")
                        print(response.statusCode)
                    } else {
                        print("ForecastBad")
                        print(response.statusCode)
                    }
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                forecast = try decoder.decode(ForecastModel.self, from: data)
                maxTemp = forecast?.DailyForecasts.first?.Temperature.Maximum.Value ?? 0
                //            minTemp = forecast?.DailyForecasts.first?.Temperature.Minimum.Value ?? 0
                minTemp = forecast?.DailyForecasts[2].Temperature.Minimum.Value ?? 0
            } catch {
                //                currents = []
            }
        }
    }
}
#Preview {
    ContentView()
}
