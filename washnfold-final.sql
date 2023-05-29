-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 29, 2023 at 05:25 AM
-- Server version: 10.4.24-MariaDB
-- PHP Version: 8.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `washnfold`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `hitung_harga_berat` (IN `p_idpemesanan` VARCHAR(4))   BEGIN
    DECLARE total_harga INT;
    DECLARE total_hargaberat INT;
    
    
    SET total_hargaberat = (
        SELECT SUM(beratpakaian * 5000)
        FROM pakaian
    );
    
    
    UPDATE pakaian
    SET hargaberat = beratpakaian * 5000 WHERE idpemesanan = p_idpemesanan;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `hitung_harga_pesanan` (IN `p_idpemesanan` VARCHAR(4))   BEGIN
    DECLARE total_harga INT;
    DECLARE total_hargaberat INT;

    SET total_hargaberat = (
        SELECT SUM(hargaberat)
        FROM pakaian
        WHERE idpemesanan = p_idpemesanan
    );

    SET total_harga = (
        SELECT hargapaket + total_hargaberat
        FROM paket
        WHERE idpaket = (
            SELECT idpaket
            FROM pemesanan
            WHERE idpemesanan = p_idpemesanan
        )
    );

    UPDATE pemesanan
    SET hargapesanan = total_harga
    WHERE idpemesanan = p_idpemesanan;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `struk` (`p_idpemesanan` VARCHAR(4)) RETURNS VARCHAR(100) CHARSET utf8mb4  BEGIN
    DECLARE struk VARCHAR(100);
    
    SELECT CONCAT(pelanggan.namapelanggan, ' - ', pemesanan.tanggal, ' - ', pemesanan.lamaproses, ' hari - Rp.', pemesanan.hargapesanan)
    INTO struk
    FROM pelanggan
    JOIN pemesanan ON pelanggan.idpelanggan = pemesanan.idpelanggan
    WHERE pemesanan.idpemesanan = p_idpemesanan;
    
    RETURN struk;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pakaian`
--

CREATE TABLE `pakaian` (
  `idpakaian` varchar(5) NOT NULL,
  `beratpakaian` int(5) NOT NULL,
  `hargaberat` int(10) NOT NULL,
  `keterangan` text NOT NULL,
  `idpemesanan` varchar(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `pakaian`
--

INSERT INTO `pakaian` (`idpakaian`, `beratpakaian`, `hargaberat`, `keterangan`, `idpemesanan`) VALUES
('00001', 3, 15000, 'Baju', '0001'),
('00002', 2, 10000, 'Celana', '0001'),
('00003', 4, 20000, 'tidak ada', '0002');

-- --------------------------------------------------------

--
-- Table structure for table `paket`
--

CREATE TABLE `paket` (
  `idpaket` int(1) NOT NULL,
  `namapaket` varchar(10) NOT NULL,
  `hargapaket` int(10) NOT NULL,
  `waktupengerjaan` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `paket`
--

INSERT INTO `paket` (`idpaket`, `namapaket`, `hargapaket`, `waktupengerjaan`) VALUES
(1, 'normal', 4000, 5),
(2, 'fast', 6000, 3),
(3, 'express', 8000, 1);

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `idpelanggan` varchar(3) NOT NULL,
  `namapelanggan` varchar(50) NOT NULL,
  `alamatpelanggan` text NOT NULL,
  `nohppelanggan` varchar(13) NOT NULL,
  `emailpelanggan` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `pelanggan`
--

INSERT INTO `pelanggan` (`idpelanggan`, `namapelanggan`, `alamatpelanggan`, `nohppelanggan`, `emailpelanggan`) VALUES
('001', 'John Doe', 'Jl. Sudirman No. 123', '081234567890', 'johndoe@example.com');

-- --------------------------------------------------------

--
-- Table structure for table `pemesanan`
--

CREATE TABLE `pemesanan` (
  `idpemesanan` varchar(4) NOT NULL,
  `lokasipengambilan` text NOT NULL,
  `lokasipengantaran` text NOT NULL,
  `tanggal` date NOT NULL,
  `lamaproses` int(2) NOT NULL,
  `hargapesanan` int(10) NOT NULL,
  `idpelanggan` varchar(3) NOT NULL,
  `idpaket` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `pemesanan`
--

INSERT INTO `pemesanan` (`idpemesanan`, `lokasipengambilan`, `lokasipengantaran`, `tanggal`, `lamaproses`, `hargapesanan`, `idpelanggan`, `idpaket`) VALUES
('0001', 'Jl. A No. 456', 'Jl. B No. 789', '2023-05-01', 0, 29000, '001', 1),
('0002', 'a', 'b', '2023-05-17', 3, 26000, '001', 2);

--
-- Triggers `pemesanan`
--
DELIMITER $$
CREATE TRIGGER `lamaproses_trigger` BEFORE INSERT ON `pemesanan` FOR EACH ROW BEGIN
    DECLARE lama_proses INT;
    
    SET lama_proses = (
        SELECT waktupengerjaan
        FROM paket
        WHERE idpaket = NEW.idpaket
    );
    
    SET NEW.lamaproses = lama_proses;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pakaian`
--
ALTER TABLE `pakaian`
  ADD PRIMARY KEY (`idpakaian`),
  ADD KEY `pemesanan_to_pakaian` (`idpemesanan`);

--
-- Indexes for table `paket`
--
ALTER TABLE `paket`
  ADD PRIMARY KEY (`idpaket`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`idpelanggan`);

--
-- Indexes for table `pemesanan`
--
ALTER TABLE `pemesanan`
  ADD PRIMARY KEY (`idpemesanan`),
  ADD KEY `pelanggan_to_pemesanan` (`idpelanggan`),
  ADD KEY `paket_to_pemesanan` (`idpaket`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `paket`
--
ALTER TABLE `paket`
  MODIFY `idpaket` int(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `pakaian`
--
ALTER TABLE `pakaian`
  ADD CONSTRAINT `pemesanan_to_pakaian` FOREIGN KEY (`idpemesanan`) REFERENCES `pemesanan` (`idpemesanan`);

--
-- Constraints for table `pemesanan`
--
ALTER TABLE `pemesanan`
  ADD CONSTRAINT `paket_to_pemesanan` FOREIGN KEY (`idpaket`) REFERENCES `paket` (`idpaket`),
  ADD CONSTRAINT `pelanggan_to_pemesanan` FOREIGN KEY (`idpelanggan`) REFERENCES `pelanggan` (`idpelanggan`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
