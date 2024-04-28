function Toggle({ activo, onClick }) {

    return (
      <label className="toggle-switch">
        <input type="checkbox" checked={activo} onChange={onClick} />
        <span className="slider"></span>
      </label>
    );
  }

  export default Toggle;