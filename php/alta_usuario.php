<?php
require_once '../config/conexion.php';

$mensaje = "";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nombre = $_POST['nombre'];
    $apellido = $_POST['apellido'];
    $dni = $_POST['dni'];
    $email = $_POST['email'];
    $telefono = $_POST['telefono'];

    $sql = "INSERT INTO usuario (nombre, apellido, dni, email, telefono) VALUES (?, ?, ?, ?, ?)";
    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("sssss", $nombre, $apellido, $dni, $email, $telefono);

    if ($stmt->execute()) {
        $mensaje = "<div class='mensaje-ok'>Usuario registrado correctamente. ID: " . $stmt->insert_id . "</div>";
    } else {
        $mensaje = "<div class='mensaje-error'>Error: " . $stmt->error . "</div>";
    }
    $stmt->close();
}

include '../includes/header.php';
?>

<h2>Alta de usuario</h2>
<?php echo $mensaje; ?>

<form method="POST" action="">
    <label>Nombre:</label>
    <input type="text" name="nombre" required>

    <label>Apellido:</label>
    <input type="text" name="apellido" required>

    <label>DNI:</label>
    <input type="text" name="dni" required>

    <label>Email:</label>
    <input type="email" name="email" required>

    <label>Teléfono:</label>
    <input type="text" name="telefono">

    <input type="submit" value="Registrar usuario">
</form>

<?php
$conexion->close();
include '../includes/footer.php';
?>