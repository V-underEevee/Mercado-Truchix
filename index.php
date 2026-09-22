<?php
require_once 'config/conexion.php';

$sql_usuarios = "SELECT COUNT(*) AS total FROM usuario";
$sql_cuentas = "SELECT COUNT(*) AS total FROM cuenta";
$sql_transacciones = "SELECT COUNT(*) AS total FROM transaccion";
$sql_saldo = "SELECT SUM(saldo) AS total FROM cuenta";

$total_usuarios = $conexion->query($sql_usuarios)->fetch_assoc()['total'];
$total_cuentas = $conexion->query($sql_cuentas)->fetch_assoc()['total'];
$total_transacciones = $conexion->query($sql_transacciones)->fetch_assoc()['total'];
$total_saldo = $conexion->query($sql_saldo)->fetch_assoc()['total'];

include 'components/header.php';
?>

<h2>Panel principal</h2>

<div class="cards">
    <div class="card">
        <h3><?php echo $total_usuarios; ?></h3>
        <p>Usuarios registrados</p>
        <a href="php/listar_usuarios.php">Ver usuarios</a>
    </div>
    <div class="card">
        <h3><?php echo $total_cuentas; ?></h3>
        <p>Cuentas activas</p>
        <a href="php/listar_cuentas.php">Ver cuentas</a>
    </div>
    <div class="card">
        <h3><?php echo $total_transacciones; ?></h3>
        <p>Transacciones</p>
        <a href="php/listar_transacciones.php">Ver transacciones</a>
    </div>
    <div class="card">
        <h3>$<?php echo number_format($total_saldo, 2, ',', '.'); ?></h3>
        <p>Saldo total en el sistema</p>
    </div>
</div>

<?php
$conexion->close();
include 'components/footer.php';
?>