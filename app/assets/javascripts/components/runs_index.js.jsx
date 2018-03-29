var RunsIndex = React.createClass({
  getInitialState() {
    return { runs: [] }
  },

  componentDidMount() {
    $.getJSON('/api/v2/runs.json', (response) => {
      this.setState({ runs: response['activity/fitbit_runs'] })
    });
  },

  handleSearch() {
    $.ajax({
      url: '/api/v2/runs',
      type: 'GET',
      data: $(".run-search-form").serialize(),
      success: (response) => {
        this.setState({ runs: response['activity/fitbit_runs'] })
      }
    });
  },

  render() {
    var locations = JSON.parse(this.props.locations.toString());
    var locationOptions = locations.map(function(loc) {
      var s = loc[0] + ", " + loc[1];
      return (
        <option key={s} value={s}>{s}</option>
      )
    });

    return (
      <div className="foo">
        <div className="jumbotron">
          <div className="container">
            <div className="pod">
              <div className="has-text-centered">
                <h5>Monthly Breakdown&nbsp;
                  <label className="switch" style={{"marginBottom":"-4px"}}>
                    <input type="checkbox"/>
                    <div className="slider round toggle-charts"></div>
                  </label>
                </h5>
              </div>
              <div id="chart-monthly-breakdown" style={{"display": "none"}}></div>
              <div id="chart-monthly-breakdown-2"></div>
            </div>
          </div>
        </div>

        <div className="container">
          <div className="row">
            <div className="col-md-3">
              <form className="run-search-form" action="/runs" acceptCharset="UTF-8" method="get">

                <div className="row">
                  <div className="col-md-12 mb-3">
                    <label for="start_date">Date</label>
                    <div className="form-row">
                      <div className="col-md-6">
                        <input type="text" className="form-control" id="start_date" name="start_date" placeholder="From" />
                      </div>
                      <div className="col-md-6">
                        <input type="text" className="form-control" id="end_date" name="end_date" placeholder="To" />
                      </div>
                    </div>
                  </div>
                </div>

                <div className="row">
                  <div className="col-md-12 mb-3">
                    <label>Distance (miles)</label>
                    <div className="form-row">
                      <div className="col-md-6">
                        <input type="text" className="form-control" id="distance_min" name="distance_min" placeholder="Min" />
                      </div>
                      <div className="col-md-6">
                        <input type="text" className="form-control" id="distance_max" name="distance_max" placeholder="Max" />
                      </div>
                    </div>
                  </div>
                </div>

                <div className="row">
                  <div className="col-md-12 mb-3">
                    <label>Duration (minutes)</label>
                    <div className="form-row">
                      <div className="col-md-6">
                        <input type="text" className="form-control" id="duration_min" name="duration_min" placeholder="Min" />
                      </div>
                      <div className="col-md-6">
                        <input type="text" className="form-control" id="duration_max" name="duration_max" placeholder="Max" />
                      </div>
                    </div>
                  </div>
                </div>

                <div className="row">
                  <div className="col-md-12 mb-3">
                    <label>Steps</label>
                    <div className="form-row">
                      <div className="col-md-6">
                        <input type="text" className="form-control" id="steps_min" name="steps_min" placeholder="Min" />
                      </div>
                      <div className="col-md-6">
                        <input type="text" className="form-control" id="steps_max" name="steps_max" placeholder="Max" />
                      </div>
                    </div>
                  </div>
                </div>

                <div className="row">
                  <div className="col-md-12 mb-3">
                    <label for="location">Location</label>
                    <select name="location" id="location" className="form-control">
                      <option value=""></option>
                      {locationOptions}
                    </select>
                  </div>
                </div>

                <div className="row">
                  <div className="col-md-12 mb-3">
                    <button type="button" className="btn btn-primary search-button" onClick={this.handleSearch}>Search</button>
                  </div>
                </div>
              </form>
            </div>

            <div className="col-md-9">
              <div className="table-responsive">
                <table id="runs-table" className="table table-sm table-hover">
                  <thead>
                    <tr>
                      <th>Date</th>
                      <th>Distance<br/>(miles)</th>
                      <th>Duration<br/>(H:MM:SS)</th>
                      <th>Pace<br/>(min/mile)</th>
                      <th>Steps</th>
                      <th>Location</th>
                    </tr>
                  </thead>
                  <Runs runs={this.state.runs} />
                </table>
              </div>
            </div>
          </div>
          <hr/>
        </div>
      </div>
    )
  }
});
