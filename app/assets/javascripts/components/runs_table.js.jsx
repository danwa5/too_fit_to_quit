var RunsTable = React.createClass({
  getInitialState() {
    return { runs: [] }
  },

  componentDidMount() {
    $.getJSON('/api/runs.json', (response) => { this.setState({ runs: response }) });
    console.log('RunsTable component mounted');
  },

  render() {
    return (
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
          <Runs runs={this.state.runs}/>
        </table>
      </div>
    )
  }
});
