var RunsIndex = React.createClass({
  getInitialState() {
    return { runs: [] }
  },

  componentDidMount() {
    $.getJSON('/api/runs.json', (response) => { this.setState({ runs: response }) });
  },

  handleSearch() {
    $.ajax({
      url: '/api/runs',
      type: 'GET',
      data: $(".run-search-form").serialize(),
      success: (response) => {
        this.setState({ runs: response })
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
        <div className="columns is-multiline">
          <div className="column is-one-quarter">
            <div className="pod">
              <form className="run-search-form" action="/runs" acceptCharset="UTF-8" method="get">
                <div className="form-group">
                  <label className=" col-xs-12 control-label" htmlFor="date">Date</label>
                  <div className="col-xs-6 col-sm-6">
                    <input type="text" name="start_date" id="start_date" className="form-control" placeholder="From" />
                  </div>
                  <div className="col-xs-6 col-sm-6">
                    <input type="text" name="end_date" id="end_date" className="form-control" placeholder="To" />
                  </div>
                </div>
                <div className="form-group">
                  <label className="col-xs-12 control-label" htmlFor="distance">Distance (miles)</label>
                  <div className="col-xs-6 col-sm-6">
                    <input type="text" name="distance_min" id="distance_min" className="form-control" placeholder="min" />
                  </div>
                  <div className="col-xs-6 col-sm-6">
                    <input type="text" name="distance_max" id="distance_max" className="form-control" placeholder="max" />
                  </div>
                </div>
                <div className="form-group">
                  <label className="col-xs-12 control-label" htmlFor="duration">Duration (minutes)</label>
                  <div className="col-xs-6 col-sm-6">
                    <input type="text" name="duration_min" id="duration_min" className="form-control" placeholder="min" />
                  </div>
                  <div className="col-xs-6 col-sm-6">
                    <input type="text" name="duration_max" id="duration_max" className="form-control" placeholder="max" />
                  </div>
                </div>
                <div className="form-group">
                  <label className="col-xs-12 control-label" htmlFor="steps">Steps</label>
                  <div className="col-xs-6 col-sm-6">
                    <input type="text" name="steps_min" id="steps_min" className="form-control" placeholder="min" />
                  </div>
                  <div className="col-xs-6 col-sm-6">
                    <input type="text" name="steps_max" id="steps_max" className="form-control" placeholder="max" />
                  </div>
                </div>
                <div className="form-group">
                  <label className="control-label" htmlFor="location">Location</label>
                  <select name="location" id="location" className="form-control">
                    <option value=""></option>
                    {locationOptions}
                  </select>
                </div>
                <button type="button" className="btn btn-primary search-button" onClick={this.handleSearch}>Search</button>
              </form>
            </div>
          </div>
          <div className="column is-three-quarters">
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
        <div className="columns">
          <div className="column">
            <div className="pod">
              <div className="table-responsive">
                <table id="runs-table" className="table table-condensed table-hover">
                  <thead>
                    <tr>
                      <th>Date</th>
                      <th>Distance<br/>(miles)</th>
                      <th>Duration<br/>(H:MM:SS)</th>
                      <th>Pace<br/>(min/mile)</th>
                      <th>Steps</th>
                      <th>Location</th>
                      <th></th>
                    </tr>
                  </thead>
                  <Runs runs={this.state.runs} />
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
});
