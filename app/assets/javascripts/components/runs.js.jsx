var Runs = React.createClass({
  render() {
    var runs = this.props.runs.map((run) => {
      return (
        <tr key={run.id}>
          <td className="runs-date">{run.start_time}</td>
          <td className="runs-distance">{run.distance}</td>
          <td className="runs-duration">{run.duration}</td>
          <td className="runs-pace">{run.pace}</td>
          <td className="runs-steps">{run.steps}</td>
          <td className="runs-location">{run.location}</td>
          <td className="text-center"><a href={"/runs/" + run.id}>Details</a></td>
        </tr>
      )
    });

    return (
      <tbody>
        {runs}
      </tbody>
    )
  }
});
