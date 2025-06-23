
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
    }
}

struct ForecastModel: Codable {
    struct Headline: Codable {
        let Text: String
    }
    let Headline: Headline
    struct DailyForecast: Codable {
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
    }
    let DailyForecasts: [DailyForecast]
}

struct ContentView: View {
    @State var currents: [CurrentModel] = []
    //@State var forecasts: [ForecastModel] = []
    @State var forecast: ForecastModel?
    @State var lastUpdated: String = ""
    @State var minTemp: Decimal = 0
    @State var maxTemp: Decimal = 0
     
//    var minMaxText: String {
//        guard let forecast = forecast,
//              let firstDay = forecast.DailyForecasts.first else { return "" }
//        let min = firstDay.Temperature.Minimum.Value
//        let max = firstDay.Temperature.Maximum.Value
//        return "Min: \(min)°C  Max: \(max)°C"
//    }
    
    var body: some View {
        VStack {
            Image(systemName: "baseball.diamond.bases")
                .font(.system(size: 180))
                .foregroundStyle(.red)
                .padding(.top, 90)
                .padding(.bottom, 10)
            Text("Calver Weather App")
                .foregroundStyle(.black)
                .font(.system(size: 28))
                .preferredColorScheme(.light)
            Text(currents.isEmpty ? "" : "\(currents[0].Temperature.Metric.Value)c")
                .font(.system(size: 56))
            Text(currents.isEmpty ? "" : "\(currents[0].WeatherText)")
                .font(.system(size: 26))
            
            Text(forecast?.DailyForecasts.isEmpty ?? true ? "" : " High:\(maxTemp)")
                .font(.system(size: 18))
            
//            HStack {
//                Text("Min:")
//                    .font(.system(size: 16))
//                Text(minTemp == 0 ? "N/A" : "\(minTemp)")
//                    .font(.system(size: 16))
//
//            }
//            HStack {
//                Text("Max:")
//                    .font(.system(size: 16))
//                Text(maxTemp == 0 ? "N/A" : "\(maxTemp)")
//                    .font(.system(size: 16))
//
//            }
//            Text(minMaxText)
//            Text(currents.isEmpty ? "" : "\(currents[0].EpochTime)")
//                .font(.system(size: 26))
//            
//            Text(forecast?.Headline.Text ?? "No forecast available")
//                .font(.system(size: 20))
//                .padding(.top, 20)
//                .padding(.bottom, 20)
            
            
            
            Spacer()
            
            Button("Refresh Data") {
                grabCurrentData()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0))
            HStack {
                Text("Last updated:")
                    .font(.system(size: 16))
                Text(lastUpdated)
                    .font(.system(size: 16))
            }
        }
        .task {
            grabCurrentData()
            grabForecastData()
        }
    }
    func grabCurrentData() {
        Task {
            do {
                let url = URL(string: "https://dataservice.accuweather.com/currentconditions/v1/55489?apikey=Qc1ej31WWglKsRnGyRNbRjA5atq9ei1H")
                let (data, response) = try await URLSession.shared.data(
                    from: url!
                )
                
                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        print("CurrentGood")
                    } else {
                        print("CurrentBad")
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
                print(lastUpdated)
            } catch {
                //                currents = []
            }
            
        }
    }
    func grabForecastData() {
    Task {
        do {
            let url = URL(string: "https://dataservice.accuweather.com/forecasts/v1/daily/1day/55489?apikey=Qc1ej31WWglKsRnGyRNbRjA5atq9ei1H&metric=true")
            let (data, response) = try await URLSession.shared.data(
                from: url!
            )
            
            if let response = response as? HTTPURLResponse {
                if (200...299).contains(response.statusCode) {
                    print("ForecastGood")
                } else {
                    print("ForecastBad")
                }
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            forecast = try decoder.decode(ForecastModel.self, from: data)
            maxTemp = forecast?.DailyForecasts.first?.Temperature.Maximum.Value ?? 0
            minTemp = forecast?.DailyForecasts.first?.Temperature.Minimum.Value ?? 0
//            print(forecast?.DailyForecasts.first?.Temperature.Maximum.Value ?? "No forecast available")
            
        } catch {
            //                currents = []
        }
    }
}
}
#Preview {
    ContentView()
}



