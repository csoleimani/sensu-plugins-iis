#!C:/opt/sensu/embedded/bin/ruby.exe
require 'sensu-plugin/metric/cli'
require 'socket'

class TotalWorkerProcessPingFailuresMetric < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: Socket.gethostname.to_s
  option :app,
         description: 'App Pool Name',
         short: '-a APP',
         long: '--apppool APP',
         default: '_TOTAL'

  def accquire_Total_Worker_Process_Ping_Failures
    temp_arr = []
    timestamp = Time.now.utc.to_i
    IO.popen("typeperf -sc 1 \"\\APP_POOL_WAS(#{config[:app]})\\Total Worker Process Ping Failures\"") { |io| io.each { |line| temp_arr.push(line) } }
    temp = temp_arr[2].split(',')[1]
    metric = temp[1, temp.length - 3].to_f
    [metric, timestamp]
  end

  def run
    values = accquire_Total_Worker_Process_Ping_Failures
    metrics = {
      WorkerProcessActivationService: {
        TotalWorkerProcessPingFailures: values[0]
      }
    }
    metrics.each do |parent, children|
      children.each do |child, value|
        output [config[:scheme], parent, child].join('.'), value, values[1]
      end
    end
    ok
  end
end
