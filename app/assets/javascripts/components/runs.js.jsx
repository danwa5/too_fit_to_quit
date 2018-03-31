var Runs = React.createClass({
  render() {
    var runs = this.props.runs.map((run) => {
      return (
        <tr key={run.id}>
          <td className="runs-date"><a href={"/runs/" + run.user_activity.id}>{run.user_activity.start_time}</a></td>
          <td className="runs-distance">{run.user_activity.distance}</td>
          <td className="runs-duration">{run.user_activity.duration}</td>
          <td className="runs-pace">{run.user_activity.pace}</td>
          <td className="runs-steps">{run.steps}</td>
          <td className="runs-location">{run.location}</td>
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
