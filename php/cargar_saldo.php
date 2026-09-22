<?php
require_once '../config/conexion.php';

$mensaje = "";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $cuenta = $_POST['cuenta'];
    $monto = $_POST['monto'];

    $sql = "CALL sp_cargar_saldo(?, ?)";
    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("id", $cuenta, $monto);

    if ($stmt->execute()) {
        $mensaje = "<div class='mensaje-ok'>Saldo cargado correctamente</div>";
    } else {
        $mensaje = "<div class='mensaje-error'>Error: " . $stmt->error . "</div>";
    }
    $stmt->close();
}

$cuentas = $conexion->query("SELECT id_cuenta, alias FROM cuenta WHERE estado = 'activa'");

include '../includes/header.php';
?>

<h2>Cargar saldo</h2>
<?php echo $mensaje; ?>

<form method="POST" action="">
    <label>Cuenta:</label>
    <select name="cuenta" required>
        <option value="">Seleccioná una cuenta</option>
        <?php while ($c = $cuentas->fetch_assoc()): ?>
            <option value="<?php echo $c['id_cuenta']; ?>"><?php echo $c['alias']; ?></option>
        <?php endwhile; ?>
    </select>

    <label>Monto a cargar:</label>
    <input type="number" step="0.01" name="monto" required>

    <input type="submit" value="Cargar saldo">
</form>

<?php
$conexion->close();
include '../includes/footer.php';
?>