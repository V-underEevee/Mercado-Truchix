<?php
require_once '../config/conexion.php';

$mensaje = "";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $origen = $_POST['origen'];
    $destino = $_POST['destino'];
    $monto = $_POST['monto'];
    $descripcion = $_POST['descripcion'];

    $sql = "CALL sp_transferir(?, ?, ?, ?)";
    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("iids", $origen, $destino, $monto, $descripcion);

    if ($stmt->execute()) {
        $resultado = $stmt->get_result();
        if ($resultado) {
            $fila = $resultado->fetch_assoc();
            $mensaje = "<div class='mensaje-ok'>" . $fila['mensaje'] . "</div>";
        } else {
            $mensaje = "<div class='mensaje-ok'>Transferencia ejecutada</div>";
        }
    } else {
        $mensaje = "<div class='mensaje-error'>Error: " . $stmt->error . "</div>";
    }
    $stmt->close();
}

$cuentas = $conexion->query("SELECT id_cuenta, alias FROM cuenta WHERE estado = 'activa'");

include '../includes/header.php';
?>

<h2>Transferir dinero</h2>
<?php echo $mensaje; ?>

<form method="POST" action="">
    <label>Cuenta origen:</label>
    <select name="origen" required>
        <option value="">Seleccioná una cuenta</option>
        <?php while ($c = $cuentas->fetch_assoc()): ?>
            <option value="<?php echo $c['id_cuenta']; ?>"><?php echo $c['alias']; ?></option>
        <?php endwhile; ?>
    </select>

    <label>Cuenta destino:</label>
    <select name="destino" required>
        <option value="">Seleccioná una cuenta</option>
        <?php
        $cuentas2 = $conexion->query("SELECT id_cuenta, alias FROM cuenta WHERE estado = 'activa'");
        while ($c = $cuentas2->fetch_assoc()):
        ?>
            <option value="<?php echo $c['id_cuenta']; ?>"><?php echo $c['alias']; ?></option>
        <?php endwhile; ?>
    </select>

    <label>Monto:</label>
    <input type="number" step="0.01" name="monto" required>

    <label>Descripción:</label>
    <input type="text" name="descripcion">

    <input type="submit" value="Transferir">
</form>

<?php
$conexion->close();
include '../includes/footer.php';
?>